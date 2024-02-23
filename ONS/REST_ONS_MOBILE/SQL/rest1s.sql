//SQL GetNewUnicode
SELECT funct_newunicode(:discrprm,:userloginprm) as unicode
//END

//SQL GetReferralCode
SELECT fn_newReferralCode() as unicode
//END

//SQL GetBalanseBonusCard
SELECT
ResultBalans.idCard AS codecard,
ResultBalans.OstBounus as OstBounus,
ResultBalans.OstMoyka as OstMoyka,
fn_get_bonus_rate(:codecard, :idGroupGoods) AS BonusRate,
fn_get_cur_moyka_rate() AS discontrate,
TableDebit.sumDeb as sumDeb,
IFNULL(get_bonus_action.action, 0) as action,
IFNULL(get_bonus_action.guid, 0) as actionguid

FROM (

		SELECT
		tbBalance.idCard AS idCard,
		SUM(tbBalance.OstBounus) AS OstBounus,
    SUM(tbBalance.OstMoyka) AS OstMoyka
    FROM (
    SELECT
    rn_cardsnakp_moyka.card AS idCard,
    0 AS OstBounus,
    rn_cardsnakp_moyka.sum AS OstMoyka
    FROM
    rn_cardsnakp_moyka
    WHERE  rn_cardsnakp_moyka.card = :idCard


    UNION ALL

    SELECT
    rn_cardsnakp.cart AS idCard,
    rn_cardsnakp.sum,
    0

    FROM  rn_cardsnakp
    WHERE rn_cardsnakp.cart = :idCard) as tbBalance

    GROUP BY tbBalance.idCard

    ) as ResultBalans

LEFT JOIN   (
             SELECT
             dc_engine_bonus_action.action,
             dc_engine_bonus_action.guid,
             dc_engine_bonus_action.card
             FROM  dc_engine_bonus_action
						 WHERE  dc_engine_bonus_action.card = :idCard and dc_engine_bonus_action.`engine` <> 1
						 ORDER BY  dc_engine_bonus_action.ondate ASC  LIMIT 1
						) as get_bonus_action  ON get_bonus_action.card = ResultBalans.idCard

LEFT JOIN  (
						SELECT
            Sum(rs_cartsnakp.sum) as sumDeb,
            rs_cartsnakp.cart as idCard
            FROM  rs_cartsnakp
            WHERE  rs_cartsnakp.cart= :idCard  GROUP BY  rs_cartsnakp.cart
					 ) as TableDebit ON TableDebit.idCard = ResultBalans.idCard

//END


//SQL GetParamCard
SELECT
cartlist.idcode as idcard,
cartlist.codcart as codecard
FROM
cartlist

WHERE
cartlist.rfid = :codecard
OR cartlist.codcart = :codecard
OR cartlist.idcode = :idcode
//END



//SQL Get_Partners_jurnal
  SELECT
  dc_engine_partners.datecreate as datecreate,
  dc_engine_partners.code_partner as codepartner,
  cartlist.codcart as codecard,
  Sum(tbdc_dc_engine_partners_spis.bonus) as amount

  FROM
  dc_engine_partners
  LEFT JOIN cartlist ON cartlist.idcode = dc_engine_partners.card
  LEFT JOIN tbdc_dc_engine_partners_spis ON dc_engine_partners.guid = tbdc_dc_engine_partners_spis.guiddoc

  WHERE
  dc_engine_partners.datecreate >= :begdate
  AND
  dc_engine_partners.datecreate < :enddate

  GROUP BY
  dc_engine_partners.datecreate,
  dc_engine_partners.code_partner,
  cartlist.codcart

//END

//SQL QueryListidGroup
  SELECT
  rf_bonus_rate.group_goods_id as idgroup
  FROM
  rf_bonus_rate
  GROUP BY
  rf_bonus_rate.group_goods_id

//END


//SQL fn_in_group_goods

SELECT fn_in_group_goods(:idGoods,:tempidgroup) as res


//END

//SQL Queryfn_get_bonus_rate

SELECT  IFNULL(fn_get_bonus_rate(:codeCard,:idgroup),0) as rate

//END

//SQL GetChangesPersonList
SELECT
persons.id,
persons.idcode,
persons.idname,
persons.idgroup,
persons.f,
persons.i,
persons.o,
persons.phone,
persons.birthday,
persons.sex,
persons.towrite,
persons.guid,
persons.codcarttemp,
persons.ReferralCode,
persons.ReferralCodeInvitation
FROM
persons AS persons
WHERE
persons.towrite = 1
//END

//SQL GetOnlineRegData
SELECT
rs_OnlineRegData.idCard,
rs_OnlineRegData.dateOfReg,
rs_OnlineRegData.phone,
rs_OnlineRegData.codecard
FROM
rs_OnlineRegData
WHERE
rs_OnlineRegData.rewrite = 0
//END


//SQL GetChangesPersonCardList

SELECT
cartlist.idcode,
cartlist.idname,
cartlist.codcart,
cartlist.ownercart,
cartlist.rfid,
cartlist.idgroup,
cartlist.`level`,
cartlist.isOnlineReg,
cartlist.towrite,
cartlist.guid
FROM
cartlist AS cartlist
WHERE
cartlist.towrite = 1
//END

//SQL GetChangesPersonsAddinfo
SELECT
rf_persons_addinfo.id,
rf_persons_addinfo.idCode,
rf_persons_addinfo.phone,
rf_persons_addinfo.EMail,
rf_persons_addinfo.sendReceipt,
rf_persons_addinfo.CityOfResidence,
rf_persons_addinfo.ReWrite
FROM
rf_persons_addinfo
WHERE
rf_persons_addinfo.ReWrite = 1
//END

//SQL GetBirthdayList
SELECT
persons.birthday as birthday,
persons.idname as PersonName,
cartlist.codcart as CodeCard,
cartlist.idcode as idCard
FROM
persons
INNER JOIN cartlist on cartlist.ownercart = persons.idcode
WHERE
DATE_FORMAT(persons.birthday ,'%m%d') =  DATE_FORMAT(CAST(:dateQuery AS DATE),'%m%d')
//END
