-- Classement des clients par nombre d'occupations
	select 	
		TJ.CLI_ID, 
		T.TIT_CODE, 
		T.CLI_NOM, 
		T.CLI_PRENOM, 
		count(CHB_PLN_CLI_OCCUPE) OCCUPATION
	from	
		T_CLIENT T, 
		TJ_CHB_PLN_CLI TJ
	where	
		T.CLI_ID = TJ.CLI_ID
	group by 
		TJ.CLI_ID
	order by 
		OCCUPATION desc;
	
-- Classement des clients par montant dépensé dans l'hôtel
	select	
		cl.CLI_ID, 
		cl.TIT_CODE, 
		cl.CLI_NOM, 
		cl.CLI_PRENOM, 
		f.FAC_ID, 
		sum(LIF_MONTANT*(1+LIF_TAUX_TVA/100)) DEPENSE
	from	
		T_CLIENT cl, 
		T_FACTURE f, 
		T_LIGNE_FACTURE lf
	where	
		cl.CLI_ID 	= f.CLI_ID
	and		
		f.FAC_ID 	= lf.FAC_ID
	group by 
		cl.CLI_ID
	order by 
		DEPENSE desc;
	
-- Classement des occupations par mois
	select 	
		count(CHB_PLN_CLI_OCCUPE) 'Nombre occupations', 
		strftime('%m',PLN_JOUR) Mois
	from	
		TJ_CHB_PLN_CLI
	group by 
		Mois;
	
-- Classement des occupations par trimestre
	select 	
		count(CHB_PLN_CLI_OCCUPE) 'Nombre occupations', 
		(strftime('%m',PLN_JOUR)+2)/3	Trimestre
	from	
		TJ_CHB_PLN_CLI
	group by 
		Trimestre;
	
-- Montant TTC de chaque ligne de facture (avec remises)
	select	
		LIF_ID, 
		LIF_QTE * 
		(LIF_MONTANT*(1+LIF_TAUX_TVA/100) - IFNULL(LIF_REMISE_MONTANT,0)) * (1-IFNULL(LIF_REMISE_POURCENT/100,0)) 'Montant TTC',
		FAC_ID
	from	
		T_LIGNE_FACTURE
	order by
		LIF_ID asc;
	
-- Classement du montant total TTC (avec remises) des factures
	select	
		LIF_ID, 
		LIF_QTE *
		sum((LIF_MONTANT*(1+LIF_TAUX_TVA/100) - IFNULL(LIF_REMISE_MONTANT,0)) * (1-IFNULL(LIF_REMISE_POURCENT/100,0))) 'Montant TTC',
		FAC_ID
	from	
		T_LIGNE_FACTURE
	group by
		FAC_ID
	order by
		FAC_ID asc;
		
-- Tarif moyen des chambres par années croissantes
	select
		AVG(TRF_CHB_PRIX) 'PRIX MOYEN',
		strftime('%Y',TRF_DATE_DEBUT) ANNEE
	from
		TJ_CHB_TRF
	group by
		ANNEE
	order by
		ANNEE asc;
		
-- Tarif moyen des chambres par étage et années croissantes
	select
		CHB_ETAGE,
		AVG(TRF_CHB_PRIX) 'PRIX MOYEN',
		strftime('%Y',TRF_DATE_DEBUT) ANNEE
	from
		T_CHAMBRE T,
		TJ_CHB_TRF TJ
	where
		TJ.CHB_ID = T.CHB_ID
	group by
		ANNEE, 
		CHB_ETAGE
	order by
		ANNEE asc;
		
-- Chambre la plus chère et en quelle année
	select
		TJ.CHB_ID,
		CHB_ETAGE,
		MAX(TRF_CHB_PRIX) 'PRIX LE PLUS ELEVE',
		strftime('%Y',TRF_DATE_DEBUT) ANNEE
	from
		T_CHAMBRE T,
		TJ_CHB_TRF TJ
	where
		TJ.CHB_ID = T.CHB_ID
	and
		TRF_CHB_PRIX = (SELECT
							MAX(TRF_CHB_PRIX)
						FROM
							TJ_CHB_TRF
						)
	group by
		TJ.CHB_ID;
		
-- Chambres réservées mais pas occupées
	select
		TJ.CHB_ID,
		T.CHB_ETAGE,
		PLN_JOUR
	from
		T_CHAMBRE T,
		TJ_CHB_PLN_CLI TJ
	where
		CHB_PLN_CLI_RESERVE = 1
	and
		CHB_PLN_CLI_OCCUPE = 0;
		
-- Taux de résa par chambre
	select
		TJ.CHB_ID,
		T.CHB_ETAGE,
		round(sum(CHB_PLN_CLI_RESERVE)*1.0/sum(CHB_PLN_CLI_OCCUPE)*100,2) 'Taux de réservation en %'
	from
		T_CHAMBRE T,
		TJ_CHB_PLN_CLI TJ
	group by
		TJ.CHB_ID,
		CHB_ETAGE;
		
-- Factures réglées avant leur édition
	select
		FAC_ID,
		FAC_DATE,
		FAC_PMT_DATE
	from
		T_FACTURE
	where
		strftime('%J',FAC_PMT_DATE) < strftime('%J',FAC_DATE);
		
-- Par qui ont été payées ces factures réglées en avance ?
	select
		f.CLI_ID,
		cl.TIT_CODE, 
		cl.CLI_NOM, 
		cl.CLI_PRENOM,
		FAC_ID,
		FAC_DATE,
		FAC_PMT_DATE
	from
		T_FACTURE f,
		T_CLIENT cl
	where
		f.CLI_ID = cl.CLI_ID
	and
		strftime('%J',FAC_PMT_DATE) < strftime('%J',FAC_DATE);
		
-- Classement des modes de paiement (par le monde et le montant totalement généré)
	select	
		round(sum((LIF_MONTANT*(1+LIF_TAUX_TVA/100) - IFNULL(LIF_REMISE_MONTANT,0)) * (1-IFNULL(LIF_REMISE_POURCENT/100,0))),2) 'Montant TTC',
		tf.PMT_CODE,
		tmp.PMT_LIBELLE
	from	
		T_LIGNE_FACTURE tlf,
		T_FACTURE tf,
		T_MODE_PAIEMENT tmp
	where
		tf.FAC_ID = tlf.FAC_ID
	and
		tf.PMT_CODE = tmp.PMT_CODE
	group by
		tmp.PMT_CODE,
		'Montant TTC';
	
-- Vous vous créez en tant que client de l'hôtel
	insert into
		T_CLIENT
		(CLI_ID, CLI_NOM, CLI_PRENOM, TIT_CODE)
	values
		(101,'BALTA','Cindy','Mme.');
		
-- N'oubliez pas vos moyens de communication
	insert into 
		T_ADRESSE
		(ADR_ID, ADR_LIGNE1, ADR_LIGNE2, ADR_LIGNE3, ADR_LIGNE4, ADR_CP, ADR_VILLE, CLI_ID)
	values
		(96, '12 rue de Dambach','','','', 67100, 'STRASBOURG', 101);
		
	insert into
		T_EMAIL
		(EML_ID,EML_ADRESSE,EML_LOCALISATION,CLI_ID)
	values
		(40, 'c.balta@ludus-academie.com', '', 101);
		
	insert into
		T_TELEPHONE
		(TEL_ID,TEL_NUMERO,TEL_LOCALISATION,CLI_ID,TYP_CODE)
	values
		(251, '06-37-32-80-45', '', 101, 'GSM');
		
-- Vous créez une nouvelle chambre à la date du jour
	insert into 
		T_CHAMBRE
		(CHB_ID, CHB_NUMERO, CHB_ETAGE, CHB_BAIN, CHB_DOUCHE, CHB_WC, CHB_COUCHAGE, CHB_POSTE_TEL)
	values
		(21, 1,'3e',1,1,1,3,121);
		
-- Vous serez 3 occupants (etc.)
	insert into
		TJ_CHB_TRF
		(TRF_CHB_PRIX, CHB_ID, TRF_DATE_DEBUT)
	values
		(512*1.3, 21, strftime('%Y-%m-%d',"now"));
	
	insert into
		TJ_CHB_PLN_CLI 
		(CHB_PLN_CLI_NB_PERS,CHB_PLN_CLI_RESERVE,CHB_PLN_CLI_OCCUPE,CHB_ID,PLN_JOUR,CLI_ID)
	values
		(3,1,1,21,strftime('%Y-%m-%d',"now"),101);
		
-- Règlement de facture en CB
	insert into
		T_FACTURE 
		(FAC_ID,FAC_DATE,CLI_ID,FAC_PMT_DATE,PMT_CODE)
	values
		(2375,strftime('%Y-%m-%d',"now"),101,'','CB');
	
	-- Nuit
	insert into
		T_LIGNE_FACTURE 
		(LIF_ID,LIF_QTE,LIF_MONTANT,LIF_TAUX_TVA,FAC_ID)
	values
		(16791,1,512*1.3,20.6,2375);
	
	-- Petits-déjeuners
	insert into
		T_LIGNE_FACTURE 
		(LIF_ID,LIF_QTE,LIF_MONTANT,LIF_TAUX_TVA,FAC_ID)
	values
		(16792,3,50*3,20.6,2375);
		
-- Une 2nde facture a été éditée car le tarif a changé : rabais de 10%
	update
		TJ_CHB_TRF
	set
		TRF_CHB_PRIX = round(	
								(
								SELECT
									TRF_CHB_PRIX
								FROM
									TJ_CHB_TRF
								WHERE
									CHB_ID = 21
								) * 0.9
							)
	where
		CHB_ID = 21;
		
	update
		T_LIGNE_FACTURE 
	set
		LIF_MONTANT = (
						SELECT
							TRF_CHB_PRIX
						FROM
							TJ_CHB_TRF
						WHERE
							CHB_ID = 21
						)
	where
		FAC_ID = 2375;