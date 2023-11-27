//SQL GetCartListByPhone

SELECT
persons.idcode AS idOwner,
persons.f,
persons.i,
persons.o,
persons.phone AS phone,
persons.birthday AS birthday,
IFNULL(persons.ReferralCode, 0) AS ReferralCode,
IFNULL(persons.ReferralCodeInvitation, 0) AS ReferralCodeInvitation,
cartlist.codcart AS codeCard,
cartlist.idcode AS idCard,
rn_cardsnakp.date AS DateOfUSE,
rf_persons_addinfo.sendReceipt as sendReceipt,
rf_persons_addinfo.EMail as EMail
FROM
persons
LEFT JOIN cartlist ON cartlist.ownercart = persons.idcode
LEFT JOIN rn_cardsnakp ON rn_cardsnakp.id = (SELECT MAX(rn_cardsnakp.id)
                  FROM rn_cardsnakp
                  WHERE rn_cardsnakp.cart = cartlist.idcode

                 )
LEFT JOIN rf_persons_addinfo ON rf_persons_addinfo.idCode = persons.idcode
WHERE
  persons.phone LIKE :Phone
  and not cartlist.codcart is null
ORDER BY
DateOfUSE DESC

//END

//SQL GetIdCodeCardByPhone
SELECT
tableIdCodeCard.idcode as  idcode
FROM
(SELECT
	cartlist.idcode as idcode
FROM
persons
LEFT JOIN cartlist ON persons.idcode = cartlist.ownercart
WHERE
  persons.phone LIKE :Phone

UNION

SELECT

rs_OnlineRegData.idCard

FROM
rs_OnlineRegData
WHERE
  rs_OnlineRegData.phone LIKE :Phone) as tableIdCodeCard
LIMIT 0,1
//END

//SQL GetCartListByCode
SELECT
persons.idcode AS idOwner,
persons.f,
persons.i,
persons.o,
persons.phone AS phone,
persons.birthday AS birthday,
IFNULL(persons.ReferralCode, 0) AS ReferralCode,
IFNULL(persons.ReferralCodeInvitation, 0) AS ReferralCodeInvitation,
cartlist.codcart AS codeCard,
cartlist.idcode AS idCard,
rn_cardsnakp.date AS DateOfUSE,
rf_persons_addinfo.sendReceipt,
rf_persons_addinfo.EMail
FROM
cartlist
LEFT JOIN persons ON cartlist.ownercart = persons.idcode
LEFT JOIN rn_cardsnakp ON rn_cardsnakp.id = (SELECT MAX(rn_cardsnakp.id)
                  FROM rn_cardsnakp
                  WHERE rn_cardsnakp.cart = cartlist.idcode

                 )
LEFT JOIN rf_persons_addinfo ON rf_persons_addinfo.idCode = persons.idcode
WHERE
  cartlist.codcart LIKE :CodeCard
ORDER BY
DateOfUSE DESC

//END

//SQL GetTransactionListBonus
SELECT
vt_Transaction.datedoc,
vt_Transaction.numberdoc,
vt_Transaction.idcart as idcard,
vt_Transaction.idshop,
vt_Transaction.guiddoc,
vt_Transaction.guidreceipt,
vt_Transaction.idgood,
vt_Transaction.quantity,
vt_Transaction.sumsale,
vt_Transaction.sumbonus,
vt_Transaction.codecart as codecard,
vt_Transaction.namegood,
vt_Transaction.fullnamegood,
rs_pricegood.price as BasePrice


		FROM (

			SELECT
      dc_enginecards.iddate AS datedoc,
      dc_enginecards.idcode as numberdoc,
      dc_enginecards.card AS idcart,
      dc_enginecards.shop AS idshop,
      dc_enginecards.guid AS guiddoc,
      dc_enginecards.uniid AS guidreceipt,
      tbdc_enginecardnac.goods AS idgood,
      tbdc_enginecardnac.quantity AS quantity,
      tbdc_enginecardnac.sum AS sumsale,
      tbdc_enginecardnac.bonus AS sumbonus,
      cartlist.codcart AS codecart,
      rf_goods.idname AS namegood,
      rf_goods.namefull AS fullnamegood
      FROM
      dc_enginecards
      LEFT JOIN tbdc_enginecardnac ON tbdc_enginecardnac.guiddoc = dc_enginecards.guid and tbdc_enginecardnac.quantity > 0
      LEFT JOIN cartlist ON cartlist.idcode = dc_enginecards.card
      LEFT JOIN rf_goods ON tbdc_enginecardnac.goods = rf_goods.idcode

      WHERE
      dc_enginecards.iddate >= :BegDate and dc_enginecards.iddate <= :EndDate) AS vt_Transaction

			LEFT JOIN rs_pricegood ON rs_pricegood.id =
									(SELECT MAX(rs_pricegood.id)
                  FROM rs_pricegood
                  WHERE rs_pricegood.shop = vt_Transaction.idshop AND rs_pricegood.good = vt_Transaction.idgood AND rs_pricegood.dateupdate <= vt_Transaction.datedoc

                 )

//END

//SQL GetParamCardMobile
SELECT
cartlist.idcode as idcard,
cartlist.codcart as codecard,
cartlist.rfid as rfid
FROM
cartlist

WHERE
cartlist.rfid = :codecard
OR cartlist.codcart = :codecard
OR cartlist.idcode = :idcode
//END

//SQL GetInfoBonusMobile
SELECT
ResultBalans.idCard AS codecard,
ResultBalans.OstBounus as OstBounus,
ResultBalans.OstMoyka as OstMoyka,
fn_get_bonus_rate(:codecard, :idGroupGoods) AS BonusRate,
fn_get_cur_moyka_rate() AS discontrate,
IFNULL(TableDebit.sumDeb, 0) as sumDeb,
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
            WHERE  rs_cartsnakp.cart= :idCard
            AND rs_cartsnakp.date > LAST_DAY(DATE_ADD(NOW(), INTERVAL -2 MONTH))
						AND rs_cartsnakp.date < DATE_ADD(LAST_DAY(DATE_ADD(NOW(), INTERVAL -1 MONTH)), INTERVAL 1 DAY)
            GROUP BY  rs_cartsnakp.cart
					 ) as TableDebit ON TableDebit.idCard = ResultBalans.idCard

//END

//SQL GetBlankCard
SELECT
cartlist.codcart as codecard,
cartlist.idcode as idcode,
cartlist.idname as idname,
cartlist.codcart as codcart,
cartlist.rfid as rfid,
cartlist.idgroup as idgroup,
cartlist.`level` as levelgroup,
cartlist.guid as guid,
cartlist.isOnlineReg as isOnlineReg,
rs_OnlineRegData.id
FROM
cartlist
LEFT JOIN rs_OnlineRegData ON rs_OnlineRegData.idCard = cartlist.idcode
WHERE
cartlist.isOnlineReg = 1 and rs_OnlineRegData.id is null
LIMIT 1
//END

//SQL GetBonusRateTable
SELECT
rfgr_goods.idname as NameGoods,
rf_bonus_rate.group_goods_id as idCoogs,
rf_bonus_rate.downmany as downAmt,
rf_bonus_rate.upmany as upAmt,
rf_bonus_rate.rate as rate,
rf_bonus_rate.periodType as periodType
FROM
rf_bonus_rate
LEFT JOIN rfgr_goods ON rf_bonus_rate.group_goods_id = rfgr_goods.idcode

//END

//SQL GetTransactionListBonusByCard
SELECT
vt_Transaction.datedoc,
vt_Transaction.numberdoc,
vt_Transaction.idcart as idcard,
vt_Transaction.idshop,
vt_Transaction.guiddoc,
vt_Transaction.guidreceipt,
vt_Transaction.idgood,
vt_Transaction.quantity,
vt_Transaction.sumsale,
vt_Transaction.sumbonus,
vt_Transaction.codecart as codecard,
vt_Transaction.namegood,
vt_Transaction.fullnamegood,
rs_pricegood.price as BasePrice


		FROM (

			SELECT
      dc_enginecards.iddate AS datedoc,
      dc_enginecards.idcode as numberdoc,
      dc_enginecards.card AS idcart,
      dc_enginecards.shop AS idshop,
      dc_enginecards.guid AS guiddoc,
      dc_enginecards.uniid AS guidreceipt,
      tbdc_enginecardnac.goods AS idgood,
      tbdc_enginecardnac.quantity AS quantity,
      tbdc_enginecardnac.sum AS sumsale,
      tbdc_enginecardnac.bonus AS sumbonus,
      cartlist.codcart AS codecart,
      rf_goods.idname AS namegood,
      rf_goods.namefull AS fullnamegood
      FROM
      dc_enginecards
      LEFT JOIN tbdc_enginecardnac ON tbdc_enginecardnac.guiddoc = dc_enginecards.guid and tbdc_enginecardnac.quantity > 0
      LEFT JOIN cartlist ON cartlist.idcode = dc_enginecards.card
      LEFT JOIN rf_goods ON tbdc_enginecardnac.goods = rf_goods.idcode

      WHERE
      dc_enginecards.iddate >= :BegDate and dc_enginecards.iddate <= :EndDate and dc_enginecards.card = :idCard) AS vt_Transaction

			LEFT JOIN rs_pricegood ON rs_pricegood.id =
									(SELECT MAX(rs_pricegood.id)
                  FROM rs_pricegood
                  WHERE rs_pricegood.shop = vt_Transaction.idshop AND rs_pricegood.good = vt_Transaction.idgood AND rs_pricegood.dateupdate <= vt_Transaction.datedoc

                 )

//END

//SQL GetOwnerCardByCode
SELECT
persons.idcode AS idOwner,
persons.f,
persons.i,
persons.o,
persons.phone AS phone,
persons.birthday AS birthday,
IFNULL(persons.ReferralCode, 0) AS ReferralCode,
IFNULL(persons.ReferralCodeInvitation, 0) AS ReferralCodeInvitation,
cartlist.codcart AS codeCard,
cartlist.idcode AS idCard
FROM
cartlist
LEFT JOIN persons ON cartlist.ownercart = persons.idcode
WHERE
  cartlist.codcart LIKE :CodeCard

//END

//SQL LastMonthSasolinePurchases
SELECT
cartlist.codcart,
Sum(IFNULL(rs_cartsnakp.sum, 0)) as summa,
Sum(IFNULL(rs_cartsnakp.quantity, 0)) as quantity
FROM
cartlist
LEFT JOIN rs_cartsnakp ON cartlist.idcode = rs_cartsnakp.cart
AND rs_cartsnakp.date > LAST_DAY(DATE_ADD(NOW(), INTERVAL -2 MONTH))
AND rs_cartsnakp.date < DATE_ADD(LAST_DAY(DATE_ADD(NOW(), INTERVAL -1 MONTH)), INTERVAL 1 DAY)
AND rs_cartsnakp.goods IN ('00000000041', '00000000038', '00000000045', '00000000049', '00000000055' , '00000041015', 'W0000002327', 'F0000000480')
WHERE
cartlist.idcode = :idCard
GROUP BY
cartlist.codcart
//END

//SQL LastYearSasolinePurchases
SELECT
cartlist.codcart,
Sum(IFNULL(rs_cartsnakpYear.sum, 0)) as summaYear,
Sum(IFNULL(rs_cartsnakpYear.quantity, 0)) as quantityYear
FROM
cartlist
LEFT JOIN rs_cartsnakp as rs_cartsnakpYear ON cartlist.idcode = rs_cartsnakpYear.cart
AND rs_cartsnakpYear.date > DATE(CONCAT(YEAR(NOW()),'-01-01'))
AND rs_cartsnakpYear.goods IN ('00000000041', '00000000038', '00000000045', '00000000049', '00000000055' , '00000041015', 'W0000002327', 'F0000000480')

WHERE
cartlist.idcode = :idCard
GROUP BY
cartlist.codcart
//END

//SQL LastSales10Minutes
SELECT
vt_Transaction.datedoc,
vt_Transaction.numberdoc,
vt_Transaction.idcart as idcard,
vt_Transaction.idshop,
vt_Transaction.guiddoc,
vt_Transaction.guidreceipt,
vt_Transaction.idgood,
vt_Transaction.quantity,
vt_Transaction.sumsale,
vt_Transaction.sumbonus,
vt_Transaction.codecart as codecard,
vt_Transaction.namegood,
vt_Transaction.fullnamegood,
rs_pricegood.price as BasePrice


		FROM (

			SELECT
      dc_enginecards.iddate AS datedoc,
      dc_enginecards.idcode as numberdoc,
      dc_enginecards.card AS idcart,
      dc_enginecards.shop AS idshop,
      dc_enginecards.guid AS guiddoc,
      dc_enginecards.uniid AS guidreceipt,
      tbdc_enginecardnac.goods AS idgood,
      tbdc_enginecardnac.quantity AS quantity,
      tbdc_enginecardnac.sum AS sumsale,
      tbdc_enginecardnac.bonus AS sumbonus,
      cartlist.codcart AS codecart,
      rf_goods.idname AS namegood,
      rf_goods.namefull AS fullnamegood
      FROM
			cartlist
			INNER JOIN dc_enginecards ON cartlist.idcode = dc_enginecards.card and dc_enginecards.iddate >= DATE_ADD(NOW(), INTERVAL -10 MINUTE)
			LEFT JOIN tbdc_enginecardnac ON tbdc_enginecardnac.guiddoc = dc_enginecards.guid and tbdc_enginecardnac.quantity > 0
      LEFT JOIN rf_goods ON tbdc_enginecardnac.goods = rf_goods.idcode

      WHERE
      cartlist.codcart = :CODECARD) AS vt_Transaction

			LEFT JOIN rs_pricegood ON rs_pricegood.id =
									(SELECT MAX(rs_pricegood.id)
                  FROM rs_pricegood
                  WHERE rs_pricegood.shop = vt_Transaction.idshop AND rs_pricegood.good = vt_Transaction.idgood AND rs_pricegood.dateupdate <= vt_Transaction.datedoc

                 )
//END

//SQL SalesForLastMonth
SELECT
card,
SUM(IF(is_fuel = 1, quantity, 0)) as quantityFuel,
SUM(IF(is_fuel = 1, summa, 0)) as sumFuel,
SUM(IF(is_service = 1, quantity, 0)) as quantityService,
SUM(IF(is_service = 1, summa, 0)) as sumService,
SUM(IF(is_tobacco = 1, quantity, 0)) as quantityTobacco,
SUM(IF(is_tobacco = 1, summa, 0)) as sumTobacco,
SUM(IF(is_tobacco = 0 and is_fuel = 0 and is_service = 0, quantity, 0)) as quantityGoods,
SUM(IF(is_tobacco = 0 and is_fuel = 0 and is_service = 0, summa, 0)) as sumGoods

FROM (

SELECT
Sum(tbdc_enginecardnac.quantity) as quantity,
Sum(tbdc_enginecardnac.sum) as summa,
dc_enginecards.card as card,
tbdc_enginecardnac.goods,
rf_goods.is_fuel as is_fuel,
rf_goods.is_service as is_service,
rf_goods.is_tobacco as is_tobacco
FROM
dc_enginecards
LEFT JOIN tbdc_enginecardnac ON tbdc_enginecardnac.guiddoc = dc_enginecards.guid
LEFT JOIN rf_goods ON rf_goods.idcode = tbdc_enginecardnac.goods
WHERE
dc_enginecards.card = :idCard
AND dc_enginecards.iddate > LAST_DAY(DATE_ADD(NOW(), INTERVAL -2 MONTH))
AND dc_enginecards.iddate < DATE_ADD(LAST_DAY(DATE_ADD(NOW(), INTERVAL -1 MONTH)), INTERVAL 1 DAY)
GROUP BY
dc_enginecards.card,
rf_goods.namefull) as tableTrade

GROUP BY
card

//END

//SQL SalesForCurrentYear
SELECT
card,
SUM(IF(is_fuel = 1, quantity, 0)) as quantityFuel,
SUM(IF(is_fuel = 1, summa, 0)) as sumFuel,
SUM(IF(is_service = 1, quantity, 0)) as quantityService,
SUM(IF(is_service = 1, summa, 0)) as sumService,
SUM(IF(is_tobacco = 1, quantity, 0)) as quantityTobacco,
SUM(IF(is_tobacco = 1, summa, 0)) as sumTobacco,
SUM(IF(is_tobacco = 0 and is_fuel = 0 and is_service = 0, quantity, 0)) as quantityGoods,
SUM(IF(is_tobacco = 0 and is_fuel = 0 and is_service = 0, summa, 0)) as sumGoods

FROM (

SELECT
Sum(tbdc_enginecardnac.quantity) as quantity,
Sum(tbdc_enginecardnac.sum) as summa,
dc_enginecards.card as card,
tbdc_enginecardnac.goods,
rf_goods.is_fuel as is_fuel,
rf_goods.is_service as is_service,
rf_goods.is_tobacco as is_tobacco
FROM
dc_enginecards
LEFT JOIN tbdc_enginecardnac ON tbdc_enginecardnac.guiddoc = dc_enginecards.guid
LEFT JOIN rf_goods ON rf_goods.idcode = tbdc_enginecardnac.goods
WHERE
dc_enginecards.card = :idCard
AND dc_enginecards.iddate > DATE(CONCAT(YEAR(NOW()),'-01-01'))
GROUP BY
dc_enginecards.card,
rf_goods.namefull) as tableTrade

GROUP BY
card


//END
