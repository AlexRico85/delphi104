//SQL Get_payment_moyka
		SELECT
		Sum(IF(dc_pay_moyka.`check` = 0, dc_pay_moyka.money, 0)) as NotCheckMoney,
    Sum(dc_pay_moyka.money) as TotalMoney,
		IF(dc_pay_moyka.operation = 23, 1, 0) as isBank,
    dc_pay_moyka.iddevice as iddevice
    FROM
    dc_pay_moyka
    WHERE
    dc_pay_moyka.guidterminal =:codeterminal AND
    dc_pay_moyka.dateadd >= :begdate AND
    (dc_pay_moyka.operation = 0 OR dc_pay_moyka.operation = 1 OR dc_pay_moyka.operation = 2 OR dc_pay_moyka.operation = 23)
    GROUP BY
    dc_pay_moyka.iddevice,
		IF(dc_pay_moyka.operation = 23, 1, 0)
//END

//SQL Get_payment_moyka_check_list
  SELECT
  dc_pay_moyka.id as id,
  dc_pay_moyka.iddevice as iddevice,
  dc_pay_moyka.dateadd as dateadd,
  dc_pay_moyka.money as money,
  dc_pay_moyka.`check` as oncheck,
	IF(dc_pay_moyka.operation = 23, 1, 0) as isBank
  FROM
  dc_pay_moyka
  WHERE
  dc_pay_moyka.guidterminal = :codeterminal AND
  dc_pay_moyka.dateadd >= :begdate  AND
  (dc_pay_moyka.operation = 0 OR dc_pay_moyka.operation = 1 OR dc_pay_moyka.operation = 2 OR dc_pay_moyka.operation = 23)
  ORDER BY
  dc_pay_moyka.id DESC
//END
