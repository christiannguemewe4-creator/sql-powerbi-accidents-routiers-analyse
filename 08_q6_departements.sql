USE accidents_routiers;

-- =============================================
-- QUESTION 6 : Quels départements sont les plus touchés ?
-- =============================================
SELECT  departement,
  COUNT(*) AS nb_usagers ,
SUM(est_tue) AS nb_tues,
 ROUND(100 * SUM(est_tue) / COUNT(*), 2)  AS taux_mortalite_pct
FROM usagers
JOIN caract USING(num_acc)
GROUP BY departement
HAVING COUNT(DISTINCT num_acc) >= 200
ORDER BY nb_tues DESC
LIMIT 10;
-- CONCLUSION (nombre de tués) :
-- En nombre de tués, les départements très peuplés sont en tête :
-- Bouches-du-Rhône (115), Gironde (83), Nord et Seine-et-Marne (71).
-- Ces 10 départements concentrent 20,3 % des tués (697 sur 3 432).
-- Pourtant, leur taux de mortalité reste bas : de 2,13 % (Bouches-du-Rhône)
-- à 4,12 % (Isère). Hypothèse : beaucoup d'accidents en ville, où la vitesse
-- est plus faible (cf. Q3).
-- Action : dans ces départements, agir sur le volume d'accidents.


SELECT  departement,
  COUNT(*) AS nb_usagers ,
SUM(est_tue) AS nb_tues,
 ROUND(100 * SUM(est_tue) / COUNT(*), 2)  AS taux_mortalite_pct
FROM usagers
JOIN caract USING(num_acc)
GROUP BY departement
HAVING COUNT(DISTINCT num_acc) >= 200
ORDER BY taux_mortalite_pct DESC
LIMIT 10;
-- CONCLUSION (taux de mortalité) :
-- En taux de mortalité, ce sont les départements ruraux qui sont en tête :
-- Vendée (6,72 %), Landes (6,61 %), Polynésie française (987, 6,50 %).
-- En Vendée, le risque de mourir est 3,15 fois plus élevé que dans les
-- Bouches-du-Rhône (2,13 %).
-- Hypothèse : plus de routes départementales hors agglomération, les plus
-- meurtrières (cf. Q3).
-- Le Gard est le seul département présent dans les deux classements :
-- 63 tués et un taux de 6,08 %.
-- Limite : ces départements comptent 30 à 63 tués, le classement reste fragile.
-- Action : agir en priorité dans le Gard, puis répartir l'effort entre
-- départements peuplés (volume de victimes) et ruraux (gravité).

