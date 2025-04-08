


-- 3. Test pour assign_asset_to_user (ROLE_IT_TECH_CERGY)
-- Cas normal
BEGIN
    assign_asset_to_user(1, 1);
    DBMS_OUTPUT.PUT_LINE('Asset assigné avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test avec asset inexistant
BEGIN
    assign_asset_to_user(999, 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- 4. Test pour change_asset_status (ROLE_IT_TECH_CERGY)
-- Cas normal
BEGIN
    change_asset_status(1, 'maintenance');
    DBMS_OUTPUT.PUT_LINE('Statut changé avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test avec statut invalide
BEGIN
    change_asset_status(1, 'invalid_status');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- 5. Test pour create_ticket (ROLE_IT_TECH_CERGY)
-- Cas normal avec asset
BEGIN
    create_ticket(1, 1, 'L''ordinateur affiche un écran bleu fréquemment');
    DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Cas normal sans asset (NULL pour asset_id)
BEGIN
    create_ticket(1, NULL, 'Demande d''accès au réseau Wi-Fi');
    DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- 6. Test pour resolve_ticket (ROLE_IT_TECH_CERGY)
-- Cas normal (supposons que l'ID 1 est un ticket)
BEGIN
    resolve_ticket(1);
    DBMS_OUTPUT.PUT_LINE('Ticket résolu avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test avec ticket inexistant
BEGIN
    resolve_ticket(999);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- 7. Test pour add_new_user (ROLE_IT_MANAGER)
-- Cas normal pour un technicien
BEGIN
    add_new_user('Paul', 'Technicien', 'ROLE_IT_TECH_CERGY', 'paul.tech@cytech.fr', 1);
    DBMS_OUTPUT.PUT_LINE('Utilisateur ajouté avec succès');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
END;
/

-- Test pour un rôle inexistant
BEGIN
    add_new_user('Marc', 'Test', 'ROLE_INEXISTANT', 'marc.test@cytech.fr', 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/

-- Test avec le rôle étudiant (qui devrait utiliser add_new_student à la place)
BEGIN
    add_new_user('Sophie', 'Étudiante', 'ROLE_STUDENT_TEACHER_CERGY', 'sophie.etu@student.cytech.fr', 1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
END;
/