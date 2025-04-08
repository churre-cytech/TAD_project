-- Déclaration des variables pour stocker les IDs des utilisateurs par rôle
DECLARE
  v_student_id NUMBER;
  v_technician_id NUMBER;
  v_it_manager_id NUMBER;
  v_employee_id NUMBER;
  v_asset_id NUMBER;
  v_ticket_id NUMBER;
BEGIN
  -- Sélection d'un étudiant de Cergy
  SELECT ua.user_id INTO v_student_id
  FROM USER_ACCOUNT ua
  JOIN USER_ROLE ur ON ua.role_id = ur.role_id
  JOIN SITE s ON ua.site_id = s.site_id
  WHERE ur.role_name = 'Student' AND s.name = 'Cergy'
  AND ROWNUM = 1;

  -- Sélection d'un technicien de Cergy
  SELECT ua.user_id INTO v_technician_id
  FROM USER_ACCOUNT ua
  JOIN USER_ROLE ur ON ua.role_id = ur.role_id
  JOIN SITE s ON ua.site_id = s.site_id
  WHERE ur.role_name = 'Technician' AND s.name = 'Cergy'
  AND ROWNUM = 1;

  -- Sélection d'un IT Manager de Cergy
  SELECT ua.user_id INTO v_it_manager_id
  FROM USER_ACCOUNT ua
  JOIN USER_ROLE ur ON ua.role_id = ur.role_id
  JOIN SITE s ON ua.site_id = s.site_id
  WHERE ur.role_name = 'IT Manager' AND s.name = 'Cergy'
  AND ROWNUM = 1;

  -- Sélection d'un employé de Cergy
  SELECT ua.user_id INTO v_employee_id
  FROM USER_ACCOUNT ua
  JOIN USER_ROLE ur ON ua.role_id = ur.role_id
  JOIN SITE s ON ua.site_id = s.site_id
  WHERE ur.role_name = 'Employee' AND s.name = 'Cergy'
  AND ROWNUM = 1;

  -- Sélection d'un asset de Cergy
  SELECT asset_id INTO v_asset_id
  FROM ASSET a
  JOIN SITE s ON a.site_id = s.site_id
  WHERE s.name = 'Cergy' AND a.status = 'active'
  AND ROWNUM = 1;

  -- Sélection d'un ticket ouvert de Cergy
  SELECT ticket_id INTO v_ticket_id
  FROM TICKET t
  JOIN SITE s ON t.site_id = s.site_id
  WHERE s.name = 'Cergy' AND t.status = 'open'
  AND ROWNUM = 1;

  -- 3. Test pour assign_asset_to_user (Technician)
  -- Cas normal
  BEGIN
    assign_asset_to_user(v_asset_id, v_employee_id);
    DBMS_OUTPUT.PUT_LINE('Asset assigné avec succès');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
  END;
  /

  -- Test avec asset inexistant
  BEGIN
    assign_asset_to_user(999, v_employee_id);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
  END;
  /

  -- 4. Test pour change_asset_status (Technician)
  -- Cas normal
  BEGIN
    change_asset_status(v_asset_id, 'maintenance');
    DBMS_OUTPUT.PUT_LINE('Statut changé avec succès');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
  END;
  /

  -- Test avec statut invalide
  BEGIN
    change_asset_status(v_asset_id, 'invalid_status');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
  END;
  /

  -- 5. Test pour create_ticket (Employee)
  -- Cas normal avec asset
  BEGIN
    create_ticket(v_employee_id, v_asset_id, 'L''ordinateur affiche un écran bleu fréquemment');
    DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
  END;
  /

  -- Cas normal sans asset (NULL pour asset_id)
  BEGIN
    create_ticket(v_employee_id, NULL, 'Demande d''accès au réseau Wi-Fi');
    DBMS_OUTPUT.PUT_LINE('Ticket créé avec succès');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur: ' || SQLERRM);
  END;
  /

  -- 6. Test pour resolve_ticket (Technician)
  -- Cas normal
  BEGIN
    resolve_ticket(v_ticket_id);
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

  -- 7. Test pour add_new_user (IT Manager)
  -- Cas normal pour un technicien
  BEGIN
    add_new_user('Paul', 'Technicien', 'Technician', 'paul.tech@cytech.fr', 1);
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
    add_new_user('Sophie', 'Étudiante', 'Student', 'sophie.etu@student.cytech.fr', 1);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erreur attendue: ' || SQLERRM);
  END;
  /
END;
/