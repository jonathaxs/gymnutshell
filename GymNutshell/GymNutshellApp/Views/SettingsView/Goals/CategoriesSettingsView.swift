// ⌘
//  GymNutshell/GymNutshellApp/Views/SettingsView/Goals/CategoriesSettingsView.swift
//
//  Propósito: Subpágina dedicada pra reordenar categorias de metas (fixas e criadas pelo usuário
//             juntas numa única lista) e editar categorias personalizadas (nome + toggle ON/OFF, excluir).
//
//  Created by Jonathas Motta (@jonathaxs) on 2026-04-20.
// ⌘

import SwiftUI
import GymNutshellCore

struct CategoriesSettingsView: View {

    @State private var items: [CategoryItem] = UnifiedCategoryOrderStore.load()
    @State private var editingCustomCategory: CustomGoalCategory? = nil

    @AppStorage(AppAccentColor.storageKey) private var storedColorRaw: String = AppAccentColor.blue.rawValue
    private var accentColor: Color { (AppAccentColor(rawValue: storedColorRaw) ?? .blue).color }

    var body: some View {
        List {
            Section(String(localized: "settings.goals.category.order.section", bundle: .gymNutshellCore)) {
                ForEach(items) { item in
                    row(for: item)
                }
                .onMove { from, to in
                    items.move(fromOffsets: from, toOffset: to)
                    UnifiedCategoryOrderStore.save(items)
                }
                .onDelete { offsets in
                    deleteItems(at: offsets)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .frame(maxWidth: 600)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .environment(\.editMode, .constant(.active))
        .navigationTitle(String(localized: "settings.goals.categories.title", bundle: .gymNutshellCore))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingCustomCategory) { category in
            EditCustomGoalCategoryView(category: category) { _ in
                items = UnifiedCategoryOrderStore.load()
            }
        }
        .onAppear {
            items = UnifiedCategoryOrderStore.load()
        }
    }

    @ViewBuilder
    private func row(for item: CategoryItem) -> some View {
        switch item {
        case .builtin(let category):
            Text(category.displayName)
                .foregroundStyle(.primary)
                .deleteDisabled(true)
        case .custom(let category):
            HStack {
                Text(category.name)
                Spacer()
                Button {
                    editingCustomCategory = category
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3)
                        .foregroundStyle(accentColor)
                }
                .buttonStyle(.borderless)
                .padding(.trailing, 12)
                .accessibilityLabel(String(localized: "a11y.button.edit.category.label",
                                           bundle: .gymNutshellCore))
                .accessibilityHint(String(localized: "a11y.button.edit.category.hint",
                                          bundle: .gymNutshellCore))
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        var deletedCustomIds: [String] = []
        for index in offsets {
            if case let .custom(c) = items[index] {
                deletedCustomIds.append(c.id)
            }
        }
        // Só categorias personalizadas podem ser removidas, ignora tentativas em fixas.
        let removableOffsets = IndexSet(offsets.filter { idx in
            if case .custom = items[idx] { return true }
            return false
        })
        items.remove(atOffsets: removableOffsets)
        UnifiedCategoryOrderStore.save(items)

        // Desvincula metas das categorias removidas.
        var goals = CustomTrackingGoalsStore.load()
        var changed = false
        for i in goals.indices {
            if let cid = goals[i].customCategoryId, deletedCustomIds.contains(cid) {
                goals[i].customCategoryId = nil
                changed = true
            }
        }
        if changed {
            CustomTrackingGoalsStore.save(goals)
        }
    }
}
