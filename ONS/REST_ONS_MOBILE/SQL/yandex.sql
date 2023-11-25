//SQL GetParamCardYandex
SELECT
cartlist.idcode as idcard,
cartlist.codcart as codecard
FROM
cartlist

WHERE
cartlist.codcart = :codecard

//END

//SQL GetInfoBonusYandex
SELECT
ResultBalans.idCard AS codecard,
ResultBalans.OstBounus as OstBounus,
ResultBalans.OstMoyka as OstMoyka,
fn_get_cur_moyka_rate() AS discontrate

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

//END

//SQL GetYandexRegData
SELECT
yandex_registration.phone,
yandex_registration.card_number,
yandex_registration.sms_code,
yandex_registration.confirm,
yandex_registration.dateOfReg,
yandex_registration.card_token,
yandex_registration.mask_login
FROM
yandex_registration
WHERE
(yandex_registration.phone = :phone OR yandex_registration.card_number = :card_number)
AND yandex_registration.confirm = 0
AND yandex_registration.sms_code = :sms_code
//END

//SQL GetYandexRegDataByCardToken
SELECT
yandex_registration.phone,
yandex_registration.card_id,
yandex_registration.card_number,
yandex_registration.sms_code,
yandex_registration.confirm,
yandex_registration.dateOfReg,
yandex_registration.card_token,
yandex_registration.mask_login
FROM
yandex_registration
WHERE
yandex_registration.card_token = :card_token
AND yandex_registration.confirm = 1
//END

//SQL GetYandexPurchaseData
SELECT
yandex_transactions_bonus.orderId,
yandex_transactions_bonus.orderExtendedId,
yandex_transactions_bonus.stationExtendedId,
yandex_transactions_bonus.cardNo,
yandex_transactions_bonus.fuelId,
yandex_transactions_bonus.cost,
yandex_transactions_bonus.count,
yandex_transactions_bonus.price,
yandex_transactions_bonus.orderDateUtc,
yandex_transactions_bonus.orderDateLocal,
yandex_transactions_bonus.rewrite,
yandex_transactions_bonus.rewriteDate,
yandex_transactions_bonus.purchaseId,
yandex_transactions_bonus.bonus,
yandex_transactions_bonus.errorCode,
yandex_transactions_bonus.errorMessage
FROM
yandex_transactions_bonus
WHERE
yandex_transactions_bonus.orderId = :orderId
//END


//SQL GetYandexPurchaseNotReWrite
SELECT
yandex_transactions_bonus.orderId,
yandex_transactions_bonus.orderExtendedId,
yandex_transactions_bonus.stationExtendedId,
yandex_transactions_bonus.cardNo,
yandex_transactions_bonus.fuelId,
yandex_transactions_bonus.cost,
yandex_transactions_bonus.count,
yandex_transactions_bonus.price,
yandex_transactions_bonus.orderDateUtc,
yandex_transactions_bonus.orderDateLocal,
yandex_transactions_bonus.rewrite,
yandex_transactions_bonus.rewriteDate,
yandex_transactions_bonus.purchaseId,
yandex_transactions_bonus.bonus,
yandex_transactions_bonus.errorCode,
yandex_transactions_bonus.errorMessage
FROM
yandex_transactions_bonus
WHERE
yandex_transactions_bonus.rewrite <> 1
//END
