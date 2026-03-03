#!/bin/bash
# i18n.sh - Internationalization support for Git Fix Manager

# Default language
GFM_LANG="${GFM_LANG:-en}"

# Translation function
_() {
    local key="$1"
    case "$GFM_LANG" in
        fr)
            case "$key" in
                "interactive_mode_title") echo "Git Fix Manager - Mode Interactif" ;;
                "mark_bug") echo "Marquer un bug" ;;
                "mark_fix") echo "Marquer une correction" ;;
                "check_fixes") echo "Vérifier les corrections" ;;
                "list_items") echo "Lister bugs/corrections" ;;
                "view_status") echo "Voir le statut" ;;
                "quit") echo "Quitter" ;;
                "bug_marked") echo "Bug marqué avec succès" ;;
                "fix_marked") echo "Correction marquée avec succès" ;;
                "all_fixes_present") echo "Toutes les corrections sont présentes" ;;
                "fixes_missing") echo "Des corrections manquent" ;;
                "description_required") echo "Description requise" ;;
                "commit_required") echo "Commit requis" ;;
                "invalid_choice") echo "Choix invalide" ;;
                "commit_not_found") echo "Commit non trouvé" ;;
                "checking_updates") echo "Vérification des mises à jour..." ;;
                "update_available") echo "Nouvelle version disponible" ;;
                "up_to_date") echo "Git Fix Manager est à jour" ;;
                "update_complete") echo "Mise à jour terminée" ;;
                "update_cancelled") echo "Mise à jour annulée" ;;
                "git_not_installed") echo "Git n'est pas installé" ;;
                "not_git_repo") echo "Vous devez être dans un repository Git" ;;
                "detector_not_found") echo "Script de détection non trouvé" ;;
                "use_fix_command") echo "Utilisez 'gfm fix' quand vous l'aurez corrigé" ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            case "$key" in
                "interactive_mode_title") echo "Git Fix Manager - Interactive Mode" ;;
                "mark_bug") echo "Mark a bug" ;;
                "mark_fix") echo "Mark a fix" ;;
                "check_fixes") echo "Check fixes" ;;
                "list_items") echo "List bugs/fixes" ;;
                "view_status") echo "View status" ;;
                "quit") echo "Quit" ;;
                "bug_marked") echo "Bug marked successfully" ;;
                "fix_marked") echo "Fix marked successfully" ;;
                "all_fixes_present") echo "All fixes are present" ;;
                "fixes_missing") echo "Some fixes are missing" ;;
                "description_required") echo "Description required" ;;
                "commit_required") echo "Commit required" ;;
                "invalid_choice") echo "Invalid choice" ;;
                "commit_not_found") echo "Commit not found" ;;
                "checking_updates") echo "Checking for updates..." ;;
                "update_available") echo "New version available" ;;
                "up_to_date") echo "Git Fix Manager is up to date" ;;
                "update_complete") echo "Update complete" ;;
                "update_cancelled") echo "Update cancelled" ;;
                "git_not_installed") echo "Git is not installed" ;;
                "not_git_repo") echo "You must be in a Git repository" ;;
                "detector_not_found") echo "Detector script not found" ;;
                "use_fix_command") echo "Use 'gfm fix' when you have fixed it" ;;
                *) echo "$key" ;;
            esac
            ;;
    esac
}

export -f _
export GFM_LANG
