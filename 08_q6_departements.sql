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

