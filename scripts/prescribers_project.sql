-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
SELECT npi, total_claim_count
FROM prescriber
	INNER JOIN prescription
	USING (npi)
ORDER BY total_claim_count DESC
LIMIT 1;

--Prescriber 1912011792 has the most claims at 4,538
    
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.
SELECT nppes_provider_first_name, 	 nppes_provider_last_org_name, 
specialty_description, 
total_claim_count
FROM prescriber
	INNER JOIN prescription
	USING (npi)
ORDER BY total_claim_count DESC
LIMIT 1;

--WE find out that the prescribers name from part A is David Coffey and he specializes in family practice

-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT specialty_description,
SUM(total_claim_count)
FROM prescriber
	INNER JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

--Family Practice has the most total claims at 9,752,347 total claims

--     b. Which specialty had the most total number of claims for opioids?
SELECT specialty_description,
SUM(total_claim_count)
FROM prescriber
	LEFT JOIN prescription
	USING (npi)
	LEFT JOIN drug
	USING (drug_name)
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description
ORDER BY SUM(total_claim_count) DESC;

--Nurse Practitioner has the highest number of claims involving opioids at 900,845 claims.

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT specialty_description,
SUM(total_claim_count)
FROM prescriber
	LEFT JOIN prescription
	USING (npi)
GROUP BY specialty_description
ORDER BY SUM(total_claim_count);

--No. Thoracic Surgery, Clinical Psychologist and Colon & Rectal Surgery all have the least prescriptions at 11 each.

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
WITH total_claim AS (
SELECT SUM(total_claim_count) AS total
FROM prescription
	INNER JOIN drug
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
WHERE opioid_drug_flag = 'Y'
)
SELECT specialty_description,
ROUND(SUM(total_claim_count)/total_claim.total*100,4) AS pct
FROM prescriber
	LEFT JOIN prescription
	USING (npi)
	LEFT JOIN drug
	USING (drug_name)
	CROSS JOIN total_claim
WHERE opioid_drug_flag = 'Y'
GROUP BY specialty_description, total_claim.total
ORDER BY SUM(total_claim_count)/total_claim.total*100 DESC;

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?
SELECT generic_name,
SUM(total_drug_cost)
FROM drug
	INNER JOIN prescription
	USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;

--Insulin Glargine had the highest toal drug cost at 104,264,066.35 monies

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT generic_name,
ROUND(SUM(total_drug_cost)/365, 2) AS cost_per_day
FROM drug
	INNER JOIN prescription
	USING (drug_name)
GROUP BY generic_name
ORDER BY SUM(total_drug_cost) DESC;

SELECT generic_name,
ROUND(SUM(total_drug_cost)/total_day_supply, 2) AS cost_per_day
FROM drug
	INNER JOIN prescription
	USING (drug_name)
GROUP BY generic_name, total_day_supply
ORDER BY SUM(total_drug_cost) DESC;

--Insulin Glargine has the highest drug cost per day at 285,654.98 monies a day.

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.
SELECT drug_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'niether' END AS drug_type
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT 
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE 'niether' END AS drug_type,
SUM(total_drug_cost)
FROM drug
	INNER JOIN prescription
	USING (drug_name)
GROUP BY drug_type
ORDER BY SUM(total_drug_cost) DESC;

--More was spent on opioids at 105,080,626.37 compared to the 38,435,121.26 for antibiotics

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT(*)
FROM cbsa
WHERE cbsaname LIKE '%TN';

--There are 33 cbsa's in Tennessee

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT cbsaname,
SUM(population) AS total_pop
FROM cbsa
	LEFT JOIN population
	USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY SUM(population) DESC;

--Nashville-Davidson-Murfreesboro-Franklin, TN has the largest combined population at 1,830,410 and Morristown, TN has the lowest combined population at 116,352

--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT county AS county_name,
population
FROM population
	INNER JOIN fips_county
	USING(fipscounty)
WHERE fipscounty NOT IN
	(SELECT fipscounty
	FROM cbsa)
ORDER BY population DESC;

--The county with the highest population not in a CBSA is Sevier county at 95,523.	

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,
total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name,
total_claim_count,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'not opioid' END
FROM prescription
	INNER JOIN drug
	USING(drug_name)
WHERE total_claim_count >= 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT drug_name,
total_claim_count,
CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
ELSE 'not opioid' END,
nppes_provider_first_name AS provider_first,
nppes_provider_last_org_name AS provider_last
FROM prescription
	INNER JOIN drug
	USING(drug_name)
	INNER JOIN prescriber
	USING(npi)
WHERE total_claim_count >= 3000;
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Managment') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.
SELECT p.npi,
d.drug_name
FROM prescriber AS p
	CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y';

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).
SELECT p.npi,
d.drug_name,
SUM(p2.total_claim_count) AS total_claim_count
FROM prescriber AS p
	CROSS JOIN drug AS d
	LEFT JOIN prescription AS p2
	ON d.drug_name = p2.drug_name
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY p.npi, d.drug_name
ORDER BY SUM(p2.total_claim_count) DESC;

SELECT npi,
drug_name,
total_claim_count
FROM prescription
WHERE npi IN
	(SELECT p.npi
FROM prescriber AS p
	CROSS JOIN drug AS d
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y');

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
SELECT p.npi,
d.drug_name,
COALESCE(SUM(p2.total_claim_count),0) AS total_claim_count
FROM prescriber AS p
	CROSS JOIN drug AS d
	LEFT JOIN prescription AS p2
	ON d.drug_name = p2.drug_name
WHERE specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND opioid_drug_flag = 'Y'
GROUP BY p.npi, d.drug_name
ORDER BY SUM(p2.total_claim_count) DESC;

--BONUS
-- 1. How many npi numbers appear in the prescriber table but not in the prescription table?
SELECT COUNT(p1.npi)-COUNT(p2.npi) AS npi_diff
FROM prescriber AS p1
	FULL JOIN prescription AS p2
	USING(npi);

--There are 4,458 more npi's in the prescriber table compared to the prescription table.

-- 2.
--     a. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Family Practice.
SELECT generic_name,
COUNT(generic_name)
FROM drug
	CROSS JOIN prescriber
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
ORDER BY COUNT(generic_name) DESC
LIMIT 5;


--     b. Find the top five drugs (generic_name) prescribed by prescribers with the specialty of Cardiology.
SELECT generic_name,
COUNT(generic_name)
FROM drug
	CROSS JOIN prescriber
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY COUNT(generic_name) DESC
LIMIT 5;

--     c. Which drugs are in the top five prescribed by Family Practice prescribers and Cardiologists? Combine what you did for parts a and b into a single query to answer this question.
SELECT generic_name,
COUNT(generic_name)
FROM drug
	CROSS JOIN prescriber
WHERE specialty_description = 'Family Practice'
GROUP BY generic_name
UNION
SELECT generic_name,
COUNT(generic_name)
FROM drug
	CROSS JOIN prescriber
WHERE specialty_description = 'Cardiology'
GROUP BY generic_name
ORDER BY COUNT(generic_name) DESC
LIMIT 5;
-- 3. Your goal in this question is to generate a list of the top prescribers in each of the major metropolitan areas of Tennessee.
--     a. First, write a query that finds the top 5 prescribers in Nashville in terms of the total number of claims (total_claim_count) across all drugs. Report the npi, the total number of claims, and include a column showing the city.
    
--     b. Now, report the same for Memphis.
    
--     c. Combine your results from a and b, along with the results for Knoxville and Chattanooga.

-- 4. Find all counties which had an above-average number of overdose deaths. Report the county name and number of overdose deaths.

-- 5.
--     a. Write a query that finds the total population of Tennessee.
    
--     b. Build off of the query that you wrote in part a to write a query that returns for each county that county's name, its population, and the percentage of the total population of Tennessee that is contained in that county.