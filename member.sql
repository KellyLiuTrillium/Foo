modified on the server
USE [Incedo]
GO

/****** Object:  StoredProcedure [dbo].[spMembersCurrent]    Script Date: 3/29/2018 2:32:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Kelly Liu
-- Create date: 4-29-2017
-- Description:	Formatting data for InfoMC
-- =============================================
CREATE PROCEDURE [dbo].[spMembersCurrent]
	-- Add the parameters for the stored procedure here
	@startDate DATETIME
,	@endDate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		CREATE TABLE #results (
			LAST_NAME	Varchar(500) NOT NULL
		,	FIRST_NAME	Varchar(500) NOT NULL
		,	MIDDLE	Varchar(500) NULL
		,	SALUTATION	Varchar(500) NULL
		,	BIRTHDATE	Varchar(500) NOT NULL
		,	SEX	Varchar(500)         NOT NULL 
		,	RACE	Varchar(500)     NOT NULL
		,	ETHNICITY	Varchar(500)NULL
		,	LANGUAGE	Varchar(500) NOT NULL
		,	RELIGION	Varchar(500) NULL
		,	EXT_ID	Varchar(500) NULL
		,	SYSTEM_ID	Varchar(500) NOT NULL
		,	ADDRESSTYPE	Varchar(500) NOT NULL
		,	ADDRESS1	Varchar(500) NOT NULL
		,	ADDRESS2	Varchar(500) NULL
		,	ADDRESS3	Varchar(500) NULL
		,	CITY	Varchar(500)     NOT NULL
		,	STATE	Varchar(500)     NOT NULL
		,	ZIP_CODE	Varchar(500) NOT NULL
		,	COUNTRY	Varchar(500)     NOT NULL
		,	COUNTY	Varchar(500)     NOT NULL
		,	ADDR_DATE_FROM	Varchar(500) NULL
		,	ADDR_DATE_TO	Varchar(500) NULL
		,	HOME_PHONE	Varchar(500) NOT NULL
		,	WORK_PHONE	Varchar(500) NULL
		,	WORK_EXT	Varchar(500) NULL
		,	OTH_PHONE	Varchar(500) NULL
		,	OTH_EXT	Varchar(500) NULL
		,	PHONE_TYPE	Varchar(500) NOT NULL
		,	MARITAL	Varchar(500)    NOT NULL
		,	SCHOOL	Varchar(500) NULL
		,	GRADE	Varchar(500) NULL
		,	Graduated_High_School	Varchar(500) NULL
		,	Living_Arrangements	Varchar(500) NULL
		,	Bed_Size	Varchar(500) NULL
		,	PREGNANT	Varchar(500) NULL
		,	DUE_DATE	Varchar(500) NULL
		,	MEMBERSTATUS	Varchar(500) NULL
		,	IN_Indicator	Varchar(500)  NULL
		,	Innovations_Tag	Varchar(500)  NULL
		,	Foster_Care_Indicator	Varchar(500) NULL
		,	Medicare_Dual_Indicator	Varchar(500) NULL
		,	Registry_Of_Unmet_Needs	Varchar(500) NULL
		,	CC_Status	Varchar(500)  NULL
		,	Care_Coordinator	Varchar(500) NULL
		,	CCNC_CM_Status	Varchar(500) NULL
		,	CCNC_Level_Of_CM	Varchar(500) NULL
		,	CCNC_Risk_Of_Readmission	Varchar(500) NULL
		,	PCPIndicator	Varchar(500)   NOT NULL
		,	PCPID	Varchar(500)        NULL
		,	PCPName	Varchar(500) NULL
		,	EmploymentIndicator	Varchar(500) NULL
		,	NOTE	Varchar(500) NULL
		,	INSUR_NUM	Varchar(500)     NOT NULL
		,	INSURANCE	Varchar(500)     NOT NULL
		,	INS_DATE_FROM	Varchar(500) NULL
		,	INS_DATE_TO	Varchar(500) NULL
		,	[PLAN]	Varchar(500) NULL
		,	[GROUP]	Varchar(500) NULL
		,	GROUP_NUMB	Varchar(500) NULL
		,	County_Of_Medicaid_Eligibility	Varchar(500) NULL
		,	Zip_Code_Of_Medicaid_Eligibility	Varchar(500) NULL
		,	TouchDate	Varchar(500)  NOT NULL
		,	EligibilityCode	Varchar(500) NULL
		,	Deceased_date	Varchar(500) NULL
		)

		-- get the latest addresses
		SELECT
			l.client_id
		,	MAX(l.cli_location_id) RecordID	
		INTO #address 
		FROM CI_QM..tbl_Client_Location l 
		INNER JOIN Incedo..MemberIDs m ON m.memberID = l.client_id 
		WHERE GETDATE() BETWEEN l.from_dt AND ISNULL(l.end_dt, '12/31/2099')
		GROUP BY l.client_id
		
		--select * from #address where client_id = 82010

		-- get the tags
		SELECT 
			ct.client_id
		,   'Y' 'Innovations'
		INTO #tags
		FROM CI_QM..tbl_client_tags ct
		JOIN CI_QM..tbl_ClientTags  tags ON tags.ClientTagsID = ct.tag_id
		WHERE tags.Description LIKE 'Innovations'
		AND tags.Active = 1
		AND ct.active = 1
		AND @startDate BETWEEN ct.eff_dt AND ISNULL(ct.end_dt, '12/31/2099')

		-- get COA coa_code for IN
		SELECT 
			c.client_id
		,	'Y' 'IN'
		INTO #IN
		FROM CI_QM..tbl_client_coa c
		WHERE c.cap_code LIKE 'IN'
		AND @startDate BETWEEN c.elig_eff_dt AND ISNULL(c.elig_exp_dt, '12/31/2099')

		INSERT INTO #results(LAST_NAME,	FIRST_NAME,	MIDDLE, BIRTHDATE,SEX,RACE,ETHNICITY, [LANGUAGE], Ext_ID, SYSTEM_ID,ADDRESSTYPE,ADDRESS1,ADDRESS2,CITY,[STATE],ZIP_CODE,COUNTRY,COUNTY, ADDR_DATE_FROM, ADDR_DATE_TO, HOME_PHONE, WORK_PHONE, OTH_PHONE
		,PHONE_TYPE,MARITAL,GRADE, Living_Arrangements,PREGNANT, IN_Indicator, Innovations_Tag, PCPIndicator,EmploymentIndicator, INSUR_NUM,INSURANCE, INS_DATE_FROM, INS_DATE_TO, [PLAN], County_Of_Medicaid_Eligibility,Zip_Code_Of_Medicaid_Eligibility, 
		TouchDate, Deceased_date)
		SELECT DISTINCT
			c.cli_last
		,	c.cli_first
		,	c.cli_middle
		,	CONVERT(VARCHAR(500), c.cli_dob, 101)
		,	s.IncedoSex 
		,	rC.IncedoLookID
		,	e.IncedoLookID
		,	l.IncedoLookID
		,	c.client_id
		,	c.client_id
		,	ISNULL(aT.IncedoLookID, 0)
		,	ISNULL(cl.addr, 'Missing')
		,	ISNULL(cl.addr2, '')
		,	ISNULL(cl.city, 'Missing')
		,	ISNULL(cl.state, '')
		,	ISNULL(cl.zip, 'Missi')
		,	'US'
		,	ISNULL(cl.county, '')
		,	CONVERT(VARCHAR(500), cl.from_dt,101)
		,	CONVERT(VARCHAR(500), cl.end_dt, 101)
		,	CASE WHEN cl.phone1_type_code IS NOT NULL AND cl.phone1_type_code = 234 THEN cl.phone1
				 WHEN cl.phone2_type_code IS NOT NULL AND cl.phone2_type_code = 234 THEN cl.phone2
				 WHEN cl.phone3_type_code IS NOT NULL AND cl.phone3_type_code = 234 THEN cl.phone3
				 ELSE ''
			END
		,	CASE WHEN cl.phone1_type_code IS NOT NULL AND cl.phone1_type_code = 235 THEN cl.phone1
				 WHEN cl.phone2_type_code IS NOT NULL AND cl.phone2_type_code = 235 THEN cl.phone2
				 WHEN cl.phone3_type_code IS NOT NULL AND cl.phone3_type_code = 235 THEN cl.phone3
				 ELSE ''
			END
		,	CASE WHEN cl.phone1_type_code IS NOT NULL AND cl.phone1_type_code NOT IN (234, 235) THEN cl.phone1
				 WHEN cl.phone2_type_code IS NOT NULL AND cl.phone1_type_code NOT IN (234, 235) THEN cl.phone2
				 WHEN cl.phone3_type_code IS NOT NULL AND cl.phone1_type_code NOT IN (234, 235) THEN cl.phone3
				 ELSE ''
			END
		,	'Home'
		,	ISNULL(m.IncedoLookID, 0)
		,	ISNULL(ed.IncedoLookID, '')
		,	la.Description
		,	c.pregnant_bit
		,	ISNULL(coa.[IN], 'N')
		,	ISNULL(coa.[IN], 'N')
		,   'N'
		,   emp.EmploymentValue
		,   LTRIM(RTRIM(i.ins_number))
		,	b.InsurerName
		,	CONVERT(VARCHAR(500), i.eff_dt, 101)
		,	CONVERT(VARCHAR(500), i.exp_dt, 101)
		,	b.PlanNumb
		,	mcc.Medicaid3DigitCountyCode
		,	i.card_zip
		,   CONVERT(VARCHAR(500), GETDATE(), 101)
		,	CONVERT(VARCHAR(500), ISNULL(IIF(c.cli_decease_dt = CONVERT(DATE, '01/01/1900'), NULL, c.cli_decease_dt), NULL), 101)
		FROM		CI_QM..tbl_Client			c
		JOIN  Incedo..MemberIDs          mC  ON mC.MemberID = c.client_id
		JOIN	Incedo..Race				rC	ON rc.Code = c.cli_race_id
		LEFT JOIN	Incedo..Ethnicity			e	ON e.Code = c.cli_ethnicity_id	
		LEFT JOIN   Incedo..Languages			l	ON l.code = c.cli_lang1_id
		LEFT JOIN   Incedo..Sex					s	ON s.code = c.cli_gender
		LEFT JOIN   #address				   ad	ON ad.client_id = c.client_id 
		LEFT JOIN	CI_QM..tbl_Client_Location  cl	ON cl.client_id = ad.client_id  AND cl.cli_location_id = ad.recordID
		LEFT JOIN   Incedo..AddressTypes        aT  ON aT.code = cl.location_type_id
		LEFT JOIN	Incedo..Marital			    m	ON m.code = c.cli_marital_status_id
		LEFT JOIN	Incedo..Grades			   ed	ON ed.code = c.education_id
		LEFT JOIN	CI_QM..tbl_LivingArrangements la ON la.LivingArrangementsID = cl.location_type_id
		LEFT JOIN   Incedo..Employment          emp ON emp.EmploymentId = c.employment_id
		LEFT JOIN   CI_QM..tbl_client_insurance  i	 ON i.client_id = c.client_id
		LEFT JOIN   Incedo..InsurerAndPlan		 b	 ON b.BenefitplanID = i.plan_id
		LEFT JOIN   CI_QM..tbl_Regions           rl  ON rl.REGION_ID = i.region_id
		LEFT JOIN   Incedo..MedicaidCountyCodes  mCC ON mCC.CountyName LIKE rl.COUNTY
		LEFT JOIN   #IN					        coa ON coa.client_id = c.client_id
		LEFT JOIN   #tags				         tags  ON tags.client_id = c.client_id
		WHERE c.active = 1
		AND	 ((@startDate BETWEEN i.eff_dt and ISNULL(i.exp_dt, '12/31/2099')) OR i.eff_dt BETWEEN @startDate AND @endDate)
		AND	 b.InsurerName IS NOT NULL
		AND  b.PlanNumb IS NOT NULL
		AND	 i.ins_number IS NOT NULL AND DATALENGTH(LTRIM(RTRIM(i.ins_number))) > 0
		AND  c.client_id NOT IN (82010) -- 82010 -- Amber Parker excluding according the decision made by Chris and the team on 10-27-2017. 

		--select * from #results where SYSTEM_ID = 82010

		-- update the phone type
		UPDATE #results
		SET PHONE_TYPE = CASE WHEN r.HOME_PHONE IS NOT NULL AND DATALENGTH(r.HOME_PHONE) > 0 THEN 'Home'
							WHEN r.WORK_PHONE IS NOT NULL AND DATALENGTH(r.WORK_PHONE) > 0 THEN 'Work'
						    ELSE 
								CASE WHEN l.phone1 IS NOT NULL AND l.phone1_type_code = 236  THEN 'School'
								     WHEN l.phone1 IS NOT NULL AND l.phone1_type_code = 237  THEN 'Cell'
									 WHEN l.phone1 IS NOT NULL AND l.phone1_type_code = 238  THEN 'Pager'
									 WHEN l.phone1 IS NOT NULL AND l.phone1_type_code = 239  THEN 'Other'
									 WHEN l.phone2 IS NOT NULL AND l.phone2_type_code = 236  THEN 'School'
								     WHEN l.phone2 IS NOT NULL AND l.phone2_type_code = 237  THEN 'Cell'
									 WHEN l.phone2 IS NOT NULL AND l.phone2_type_code = 238  THEN 'Pager'
									 WHEN l.phone2 IS NOT NULL AND l.phone2_type_code = 239  THEN 'Other'
									 WHEN l.phone3 IS NOT NULL AND l.phone3_type_code = 236  THEN 'School'
								     WHEN l.phone3 IS NOT NULL AND l.phone3_type_code = 237  THEN 'Cell'
									 WHEN l.phone3 IS NOT NULL AND l.phone3_type_code = 238  THEN 'Pager'
									 WHEN l.phone3 IS NOT NULL AND l.phone3_type_code = 239  THEN 'Other'
									 ELSE 'other'
								END
						END
		FROM #results r
		INNER JOIN #address a ON a.client_id = r.SYSTEM_ID
		INNER JOIN CI_QM..tbl_client_location l ON l.client_id = a.client_id and a.RecordID = l.cli_location_id
		
		-- formatting phone number
		UPDATE #results
		SET HOME_PHONE = Incedo.dbo.FormatPhone(HOME_PHONE)

		UPDATE #results
		SET WORK_PHONE = Incedo.dbo.FormatPhone(WORK_PHONE)

		UPDATE #results
		SET OTH_PHONE = Incedo.dbo.FormatPhone(OTH_PHONE)

		-- update PCP
		;WITH coaRecord (client_id, RecordID)
		AS (
		SELECT 
				coa.client_id
			,	MAX(coa.client_coa_id) RecordID
		FROM CI_QM..tbl_client_coa coa
		WHERE coa.elig_pcp IS NOT NULL AND DATALENGTH(coa.elig_pcp) > 0
		AND coa.elig_exp_dt > @endDate -- current
		GROUP BY coa.client_id
		)

		UPDATE #results
		SET PCPIndicator = 'Y'
		,	PCPID = tbl.elig_pcp
		,	PCPName = tbl.FullName
		FROM #results rs
		CROSS APPLY (
			SELECT DISTINCT
				coa.client_id
			,	coa.elig_pcp
			,	npi.FullName
			FROM CI_QM..tbl_client_coa  coa
			JOIN Incedo..MemberIDs  m ON m.MemberID = coa.client_id
			JOIN CI_BIW.dw.dimNPI npi ON npi.NPI = coa.elig_pcp
			JOIN coaRecord         r ON r.RecordID = coa.client_coa_id
			WHERE npi.ETLCurrentRow = 1
			AND rs.SYSTEM_ID = coa.client_id
			) tbl

		-- add cob
		SELECT DISTINCT
			r.LAST_NAME	
		,	r.FIRST_NAME	
		,	r.MIDDLE	
		,	r.SALUTATION
		,	r.BIRTHDATE
		,	r.SEX	
		,	r.RACE
		,	r.ETHNICITY	
		,	r.LANGUAGE
		,	r.RELIGION
		,	r.EXT_ID	
		,	r.SYSTEM_ID
		,	r.ADDRESSTYPE
		,	r.ADDRESS1	
		,	r.ADDRESS2
		,	r.ADDRESS3
		,	r.CITY	
		,	r.STATE	
		,	r.ZIP_CODE
		,	r.COUNTRY	
		,	r.COUNTY	
		,	r.ADDR_DATE_FROM	
		,	r.ADDR_DATE_TO	
		,	r.HOME_PHONE	
		,	r.WORK_PHONE	
		,	r.WORK_EXT	
		,	r.OTH_PHONE	
		,	r.OTH_EXT	
		,	r.PHONE_TYPE
		,	r.MARITAL	
		,	r.SCHOOL	
		,	r.GRADE	
		,	r.Graduated_High_School	
		,	r.Living_Arrangements	
		,	r.Bed_Size	
		,	r.PREGNANT	
		,	r.DUE_DATE	
		,	r.MEMBERSTATUS
		,	r.IN_Indicator
		,	r.Innovations_Tag	
		,	r.Foster_Care_Indicator	
		,	r.Medicare_Dual_Indicator	
		,	r.Registry_Of_Unmet_Needs	
		,	r.CC_Status	
		,	r.Care_Coordinator	
		,	r.CCNC_CM_Status	
		,	r.CCNC_Level_Of_CM
		,	r.CCNC_Risk_Of_Readmission	
		,	r.PCPIndicator	
		,	r.PCPID	
		,	r.PCPName	
		,	r.EmploymentIndicator	
		,	r.NOTE	
		,	IIF(DATALENGTH(RTRIM(LTRIM(cob.OTH_INSUR_NUM))) = 0, 'FROM GEF', RTRIM(LTRIM(cob.OTH_INSUR_NUM)))  INSUR_NUM
		,	i.InsurerName					 INSURANCE
		,	CONVERT(VARCHAR(500), cob.OTH_EFF_DATE,101)   INS_DATE_FROM
		,	CONVERT(VARCHAR(500), cob.OTH_EXP_DATE, 101)  INS_DATE_TO
		,	i.PlanNumb					     [PLAN]
		,	RTRIM(LTRIM(cob.OTH_GROUP))      [GROUP]
		,	r.GROUP_NUMB	
		,	''   County_of_Elig
		,	''   Zip_codeOf_county
		,	r.TouchDate	
		,	r.EligibilityCode	
		,	r.Deceased_date	
		INTO #cob
		FROM #results	r
		JOIN		CI_QM..tbl_cob			cob		ON cob.CLIENT_ID = r.SYSTEM_ID
		LEFT JOIN	    Incedo..InsurerAndPlan  i       ON cob.OTH_INSURANCE LIKE i.plan_desc
		WHERE 
			(@startDate BETWEEN cob.oth_eff_date AND ISNULL(cob.OTH_EXP_DATE, '12/31/2099') OR cob.OTH_EFF_DATE BETWEEN @startDate AND @endDate)
		AND cob.OTH_INSURANCE LIKE 'Medicare%'
		AND i.PlanNumb IS NOT NULL
		AND i.InsurerName IS NOT NULL

		SELECT * 
		INTO #final
		FROM #results
		UNION
		SELECT * FROM #cob

		-- save home phone to alternate phone if alternate phone is null -- doing this is to keep the phone number from overwritten in Incedo
		UPDATE #final
		SET OTH_PHONE = HOME_PHONE
		WHERE DATALENGTH(OTH_PHONE) = 0
		AND DATALENGTH(HOME_PHONE) > 0
		
		-- alter the address if the member is in IDD database  SOME ONE HAS bad address in IDD
		UPDATE #final
		SET ADDRESS1 = c.AddressLine1
		,	ADDRESS2 = c.AddressLine2
		,	CITY	 = c.City
		,	STATE    = c.State
		,	ZIP_CODE = c.Zip   
		FROM IDD..Consumers c
		WHERE c.ConsumerID = #final.SYSTEM_ID
		AND c.AddressLine1 IS NOT NULL
		AND c.City IS NOT NULL
		AND c.State IS NOT NULL
		AND c.Zip IS NOT NULL

		-- delete 
		TRUNCATE TABLE MembersCurrent;

		----save the data to a table
		INSERT INTO MembersCurrent
		SELECT  * FROM #final

		--SELECT DISTINCT
		--SYSTEM_ID
		--,LAST_NAME
		--,IN_Indicator
		--,Innovations_Tag
		--INTO #indicator
		--FROM #final

		--SELECT r.* FROM #final r
		--WHERE r.SYSTEM_ID IN (

		--SELECT tbl.SYSTEM_ID FROM (
		--SELECT r.SYSTEM_ID, ROW_NUMBER()OVER(PARTITION BY r.SYSTEM_ID ORDER BY r.LAST_NAME) RN FROM #indicator r
		--) tbl
		--WHERE tbl.RN > 1
		--)
		--ORDER BY SYSTEM_ID
		
		--DROP TABLE #indicator

		DROP TABLE #address
		DROP TABLE #final
		DROP TABLE #cob
		DROP TABLE #tags
		DROP TABLE #results

END


GO


