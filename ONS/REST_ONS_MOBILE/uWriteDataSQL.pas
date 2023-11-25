unit uWriteDataSQL;

interface

uses
  System.SysUtils, structures, FireDAC.Comp.Client;


Function WriteToMySQL_dc_engine_pay_moyka(dc_engine_pay_moyka: Tdc_engine_pay_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_ddc_enginecards(dc_enginecards: Tdc_enginecards; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_CardPerson(Card: TCard; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_Person(InfoPersone: TInfoPersone; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_PersoneAddInfo(PersoneAddInfo: TPersoneAddInfo; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;

Function WriteToMySQL_OnlineRegData(OnlineRegData: TOnlineRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function UpdateMySQL_OnlineRegData(OnlineRegData: TOnlineRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_PrepaymentCarWash(MoykaRecord: TPrepayment_MoykaRecord; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;

Function UpdateMySQL_YandexRegData(YandexRegData: TYandexRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteMySQL_yandex_transactions_bonus(YandexPurchase: TYandexPurchase; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function UpdateMySQL_YandexPurchaseAnswer(YandexPurchaseAnswer: TYandexPurchaseAnswer; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;

Function WriteToMySQL_dc_enginefixcards_moyka(dc_enginefixcards_moyka: Tdc_enginefixcards_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
Function WriteToMySQL_dc_enginedebit_moyka(dc_enginedebit_moyka: Tdc_enginedebit_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;

implementation

uses
  uLog, FuctionsUnit;


Function WriteToMySQL_dc_engine_pay_moyka(dc_engine_pay_moyka: Tdc_engine_pay_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  curGuid :string;
  I: Integer;
begin
      LogFile.WriteLog('Обработка dc_engine_pay_moyka ' + dc_engine_pay_moyka.guiddocInteger);

      ADOQuerySend := TFDQuery.Create(nil);
      ADOQuerySend.Connection := ADOMySQLConnection;
   try

      // Шапка документа
      ADOQuerySend.SQL.Text := 'SELECT * FROM dc_engine_pay_moyka WHERE guid=''' + dc_engine_pay_moyka.guiddoc + '''  or guid=''' + dc_engine_pay_moyka.guiddocInteger + ''' ';

      try
        ADOQuerySend.Open;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      if ADOQuerySend.RecordCount = 0 then
      begin
          ADOQuerySend.SQL.Text := 'INSERT INTO `dc_engine_pay_moyka`  (`idcode`,`iddate`,`comment`,`guid`) VALUES (' +
          '''' + dc_engine_pay_moyka.idcode + ''',' +
          '''' + dc_engine_pay_moyka.iddate + ''',' +
          '''' + dc_engine_pay_moyka.comment + ''',' +
          '''' + dc_engine_pay_moyka.guiddocInteger + ''')';
          curGuid :=  dc_engine_pay_moyka.guiddocInteger;
      end
      else
      begin
          ADOQuerySend.First;
          curGuid := ADOQuerySend.FieldByName('guid').AsString;

          ADOQuerySend.SQL.Text := 'update dc_engine_pay_moyka set ' +
          '`guid` = ''' + dc_engine_pay_moyka.guiddocInteger +''', ' +
          '`iddate` = ''' + dc_engine_pay_moyka.iddate +''', ' +
          '`idcode` = ''' + dc_engine_pay_moyka.idcode + ''', ' +
          '`comment` = ''' + dc_engine_pay_moyka.comment + ''' ' +
          ' WHERE guid  = ''' + dc_engine_pay_moyka.guiddoc + ''' or guid=''' + dc_engine_pay_moyka.guiddocInteger + ''' ';
      end;

      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      // Очистка регистров, команда проведения отдельным запросом
      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_moyka` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      curGuid := dc_engine_pay_moyka.guiddocInteger;

      if dc_engine_pay_moyka.Registr then
      begin
          for I := Low(dc_engine_pay_moyka.tbdc_Moyka) to High(dc_engine_pay_moyka.tbdc_Moyka) do
          begin

            // Регистр накопления остати баллов мойка
            ADOQuerySend.SQL.Text :=

            'INSERT INTO rn_cardsnakp_moyka (guiddoc, card, sum) VALUES (''' +
              curGuid + ''',''' +                               // guiddoc
              dc_engine_pay_moyka.tbdc_Moyka[I].card + ''',' +  // card
              DecToch(FloatToStr(dc_engine_pay_moyka.tbdc_Moyka[I].moyka)) +   // sum
              ')';

            try
              ADOQuerySend.ExecSQL;
            except
              on E: Exception do
              begin
                result := false;
                ErrorDescription := E.Message;
                exit;
              end;
            end;

            // Регистр накопления остати баллов
            if dc_engine_pay_moyka.tbdc_Moyka[I].bonus>0 then
            begin
              ADOQuerySend.SQL.Text :=
              'INSERT INTO rn_cardsnakp (guiddoc, cart, sum, date) VALUES (''' +
                curGuid + ''',''' + // guiddoc
                dc_engine_pay_moyka.tbdc_Moyka[I].card + ''',''' + // card
                DecToch(FloatToStr(dc_engine_pay_moyka.tbdc_Moyka[I].bonus)) + ''',''' +             // sum
                dc_engine_pay_moyka.iddate + // date
                ''')';
              try
                ADOQuerySend.ExecSQL;
              except
                on E: Exception do
                begin
                  result := false;
                  ErrorDescription := E.Message;
                  exit;
                end;
              end;
            end;
          end;
      end;


   finally
     ADOQuerySend.Free;
   end;

   result := true;

end;


Function WriteToMySQL_ddc_enginecards(dc_enginecards: Tdc_enginecards; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  curGuid :string;
  I: Integer;
begin
      LogFile.WriteLog('Обработка dc_enginecards ' + dc_enginecards.guiddocInteger);

      ADOQuerySend := TFDQuery.Create(nil);
      ADOQuerySend.Connection := ADOMySQLConnection;
   try

      // Шапка документа
      ADOQuerySend.SQL.Text := 'SELECT * FROM dc_enginecards WHERE guid=''' + dc_enginecards.guiddoc + '''  or guid=''' + dc_enginecards.guiddocInteger + ''' ';

      try
        ADOQuerySend.Open;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      if ADOQuerySend.RecordCount = 0 then
      begin
          ADOQuerySend.SQL.Text := 'INSERT INTO `dc_enginecards`  (`idcode`,`iddate`,`datecreate`,`card`,`shop`,`guid`,`uniid`) VALUES (' +
          '''' + dc_enginecards.idcode + ''',' +
          '''' + dc_enginecards.iddate + ''',' +
          '''' + dc_enginecards.datecreate + ''',' +
          '''' + dc_enginecards.card + ''',' +
          '''' + dc_enginecards.shop + ''',' +
          '''' + dc_enginecards.guiddocInteger + ''',' +
          '''' + dc_enginecards.uniid + ''')';
          curGuid :=  dc_enginecards.guiddocInteger;
      end
      else
      begin
          ADOQuerySend.First;
          curGuid := ADOQuerySend.FieldByName('guid').AsString;

          ADOQuerySend.SQL.Text := 'update dc_enginecards set ' +
          '`guid` = '''       + dc_enginecards.guiddocInteger +''', ' +
          '`iddate` = '''     + dc_enginecards.iddate +''', ' +
          '`idcode` = '''     + dc_enginecards.idcode + ''', ' +
          '`datecreate` = ''' + dc_enginecards.datecreate + ''', ' +
          '`card` = '''       + dc_enginecards.card + ''', ' +
          '`shop` = '''       + dc_enginecards.shop + ''', ' +
          '`uniid` = '''      + dc_enginecards.uniid + ''' ' +
          ' WHERE guid  = ''' + dc_enginecards.guiddoc + ''' or guid=''' + dc_enginecards.guiddocInteger + ''' ';
      end;

      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      // Очистка регистров, команда проведения отдельным запросом
      ADOQuerySend.SQL.Text := 'DELETE FROM `tbdc_enginecardnac` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      ADOQuerySend.SQL.Text := 'DELETE FROM `tbdc_enginecardspis` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      ADOQuerySend.SQL.Text := 'DELETE FROM `tbdc_enginecards_share` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rs_cartsnakp` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_share` WHERE guiddoc=''' + curGuid + ''' ' + ' and typeDoc='''+'dc_enginecards'+''' ;';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      curGuid := dc_enginecards.guiddocInteger;

      if dc_enginecards.Registr then
      begin
          for I := Low(dc_enginecards.tbdc_enginecardnac) to High(dc_enginecards.tbdc_enginecardnac) do
          begin
              with dc_enginecards.tbdc_enginecardnac[I] do
              begin

                ADOQuerySend.SQL.Text := 'INSERT INTO `tbdc_enginecardnac`  (`iddoc`,`goods`,`quantity`,`sum`,`bonus`,`guiddoc`) VALUES (' +
                '''' + iddoc + ''',' +
                '''' + goods + ''',' +
                '' + DecToch(FloatToStr(quantity)) + ',' +
                '' + DecToch(FloatToStr(sum)) + ',' +
                '' + DecToch(FloatToStr(bonus)) + ',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                 ADOQuerySend.SQL.Text := 'INSERT INTO `rs_cartsnakp`  (`cart`,`sum`,`goods`,`quantity`,`date`,`guiddoc`) VALUES (' +
                '''' + card + ''',' +
                '' + DecToch(FloatToStr(sum)) + ',' +
                '''' + goods + ''',' +
                '' + DecToch(FloatToStr(quantity)) + ',' +
                '''' + date + ''',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp`  (`cart`,`sum`,`date`,`actionextcode`,`guiddoc`) VALUES (' +
                '''' + card + ''',' +
                '' + DecToch(FloatToStr(bonus)) + ',' +
                '''' + date + ''',' +
                '''' + actionextcode + ''',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

              end;
          end;

          for I := Low(dc_enginecards.tbdc_enginecardspis) to High(dc_enginecards.tbdc_enginecardspis) do
          begin
              with dc_enginecards.tbdc_enginecardspis[I] do
              begin
                ADOQuerySend.SQL.Text := 'INSERT INTO `tbdc_enginecardspis`  (`iddoc`,`goods`,`quantity`,`bonus`,`guiddoc`) VALUES (' +
                '''' + iddoc + ''',' +
                '''' + goods + ''',' +
                '' + DecToch(FloatToStr(quantity)) + ',' +
                '' + DecToch(FloatToStr(bonus)) + ',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp`  (`cart`,`sum`,`date`,`guiddoc`) VALUES (' +
                '''' + card + ''',' +
                '' +' -'+DecToch(FloatToStr(bonus)) + ',' +
                '''' + date + ''',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

              end;
          end;
          for I := Low(dc_enginecards.tbdc_enginecards_share) to High(dc_enginecards.tbdc_enginecards_share) do
          begin
              with dc_enginecards.tbdc_enginecards_share[I] do
              begin
                ADOQuerySend.SQL.Text := 'INSERT INTO `tbdc_enginecards_share`  (`iddoc`,`goods`,`share`,`value`,`guiddoc`) VALUES (' +
                '''' + iddoc + ''',' +
                '''' + goods + ''',' +
                '''' + share + ''',' +
                '' + DecToch(FloatToStr(value)) + ',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_share`  (`card`,`share`,`value`,`date`,`typeDoc`,`guiddoc`) VALUES (' +
                '''' + card + ''',' +
                '''' + share + ''',' +
                '' + DecToch(FloatToStr(value)) + ',' +
                '''' + date + ''',' +
                '''' + 'dc_enginecards' + ''',' +
                '''' + curGuid + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

              end;
          end;
      end;


   finally
     ADOQuerySend.Free;
   end;

   result := true;

end;



Function WriteToMySQL_CardPerson(Card: TCard; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try
    LogFile.WriteLog('Обработка cartlist' + Card.idcode);

    ADOQuerySend.SQL.Text := 'SELECT * FROM cartlist WHERE idcode=''' + Card.idcode + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ADOQuerySend.SQL.Text :=
        'INSERT INTO `cartlist`  (`idcode`,`idname`,`codcart`,`ownercart`,`rfid`,`idgroup`,`level`,`isOnlineReg`,`towrite`,`guid`) VALUES ('
        +
      // idcode
        '''' + Card.idcode + ''',' +
      // idname
        '''' + Card.idname + ''',' +
      // codcart
        '''' + Card.codecard + ''',' +
      // ownercart
        '''' + Card.ownercart + ''',' +
      // rfid
        '''' + Card.rfid + ''',' +
      // idgroup
        '''' + Card.idgroup + ''',' +
      // level
        '' + Card.level + ',' +
      // isOnlineReg
        '' + IntToStr(Card.isOnlineReg) + ',' +
      // towrite
        '' + IntToStr(Card.towrite) + ',' +
      // guid
        '' + Card.guid + ')';

    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update cartlist set ' +
      // idname
        '`idname` = ''' + Card.idname + ''', ' +
      // codcart
        '`codcart` = ''' + Card.codecard + ''', ' +
      // rfid
        '`rfid` = ''' + Card.rfid + ''', ' +
      // ownercart
        '`ownercart` = ''' + Card.ownercart + ''', ' +
      // idgroup
        '`idgroup` = ''' + Card.idgroup + ''', ' +
      // level
        '`level` = ' + Card.level + ', ' +
      // isOnlineReg
        '`isOnlineReg` = ' + IntToStr(Card.isOnlineReg) + ', ' +
      // towrite
        '`towrite` = ' + IntToStr(Card.toWrite) + ', ' +
      // guid
        '`guid` = ' + Card.guid + ' ' +
      // WHERE
        ' WHERE idcode  = ''' + Card.idcode + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;



Function WriteToMySQL_Person(InfoPersone: TInfoPersone; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

    ADOQuerySend.SQL.Text := 'SELECT * FROM persons WHERE idcode=''' + InfoPersone.idcode + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ADOQuerySend.SQL.Text :=
        'INSERT INTO `persons`  (`idcode`,`idname`,`idgroup`,`f`,`i`,`o`,`phone`,`birthday`,`sex`,`towrite`, `guid`, `ReferralCode`, `ReferralCodeInvitation`) VALUES ('
        +
      // idcode
        '''' + InfoPersone.idcode + ''',' +
      // idname
        '''' + InfoPersone.name + ''',' +
      // idgroup
        '''' + InfoPersone.idGroup + ''',' +
      // f
        '''' + InfoPersone.f + ''',' +
      // i
        '''' + InfoPersone.i + ''',' +
      // o
        '''' + InfoPersone.o + ''',' +
      // phone
        '''' + InfoPersone.phone + ''',' +
      // birthday
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',InfoPersone.birthday) + ''',' +
      // sex
        '''' + InfoPersone.sex + ''',' +
     // towrite
        '' + IntToStr(InfoPersone.toWrite) + ',' +
      // guid
        '' + InfoPersone.guid + ',' +
      // ReferralCode
      '' + IntToStr(InfoPersone.ReferralCode) + ',' +
      // ReferralCodeInvitation
      '' + IntToStr(InfoPersone.ReferralCodeInvitation) + ')';

    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update persons set ' +
      // idname
        '`idname` = ''' + InfoPersone.name + ''', ' +
      // idGroup
        '`idGroup` = ''' + InfoPersone.idGroup + ''', ' +
      // f
        '`f` = ''' + InfoPersone.f + ''', ' +
      // i
        '`i` = ''' + InfoPersone.i + ''', ' +
      // o
        '`o` = ''' + InfoPersone.o + ''', ' +
      // phone
        '`phone` = ''' + InfoPersone.phone + ''', ' +
      // birthday
        '`birthday` = ''' + FormatDateTime('yyyy-mm-dd hh:mm:ss',InfoPersone.birthday) + ''', ' +
     // sex
       '`sex` = ''' + InfoPersone.sex + ''', ' +
     // towrite
       '`towrite` = ' + IntToStr(InfoPersone.toWrite) + ', ' +
      // guid
        '`guid` = ' + InfoPersone.guid + ', ' +
      // ReferralCode
       '`ReferralCode` = ' + IntToStr(InfoPersone.ReferralCode) + ', ' +
      // ReferralCodeInvitation
       '`ReferralCodeInvitation` = ' + IntToStr(InfoPersone.ReferralCodeInvitation) + ' ' +
      // WHERE
        ' WHERE idcode  = ''' + InfoPersone.idcode + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;

Function WriteToMySQL_PersoneAddInfo(PersoneAddInfo: TPersoneAddInfo; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

    ADOQuerySend.SQL.Text := 'SELECT * FROM rf_persons_addinfo WHERE idcode=''' + PersoneAddInfo.idcode + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ADOQuerySend.SQL.Text :=
        'INSERT INTO `rf_persons_addinfo`  (`idcode`, `phone`,`EMail`,`sendReceipt`,`CityOfResidence`,`rewrite`) VALUES ('
        +
      // idcode
        '''' + PersoneAddInfo.idCode + ''',' +
     // phone
        '''' + PersoneAddInfo.phone + ''',' +
      // EMail
        '''' + PersoneAddInfo.Email + ''',' +
      // sendReceipt
        '' + IntToStr(PersoneAddInfo.sendReceipt) + ',' +
      // CityOfResidence
        '''' + PersoneAddInfo.CityOfResidence + ''',' +
      // rewrite
        '' + IntToStr(PersoneAddInfo.rewrite) + ')';

    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update rf_persons_addinfo set ' +
      // EMail
        '`EMail` = ''' + PersoneAddInfo.Email + ''', ' +
      // phone
        '`phone` = ''' + PersoneAddInfo.phone + ''', ' +
      // sendReceipt
        '`sendReceipt` = ''' + IntToStr(PersoneAddInfo.sendReceipt) + ''', ' +
      // CityOfResidence
        '`CityOfResidence` = ''' + PersoneAddInfo.CityOfResidence + ''', ' +
      // rewrite
        '`rewrite` = ' + IntToStr(PersoneAddInfo.rewrite) + ' ' +
      // WHERE
        ' WHERE idcode  = ''' + PersoneAddInfo.idcode + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if PersoneAddInfo.ReferralCodeInvitation > 0  then
    begin

      ADOQuerySend.SQL.Text := 'SELECT * FROM persons WHERE idcode=''' + PersoneAddInfo.idcode + ''' ';

      try
        ADOQuerySend.Open;
      except
        on E: Exception do
        begin
          result := false;
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      if ADOQuerySend.RecordCount > 0 then
      begin
        ADOQuerySend.SQL.Text := 'update persons set ' +
       // ReferralCodeInvitation
       '`ReferralCodeInvitation` = ' + IntToStr(PersoneAddInfo.ReferralCodeInvitation) + ', ' +
       '`towrite` = 1' +
       // WHERE
       ' WHERE idcode  = ''' + PersoneAddInfo.idcode + ''' ';


        try
         ADOQuerySend.ExecSQL;
         result := true;
        except
        on E: Exception do
          begin
            result := false;
            ErrorDescription := E.Message;
            exit;
          end;
        end;
      end;

    end;


  finally
    ADOQuerySend.Free;
  end;



end;

Function WriteToMySQL_OnlineRegData(OnlineRegData: TOnlineRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

      ADOQuerySend.SQL.Text :=
        'INSERT INTO `rs_OnlineRegData`  (`idCard`,`dateOfReg`,`phone`,`codecard`) VALUES ('
        +
      // idcode
        '''' + OnlineRegData.idCard + ''',' +
      // idname
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', OnlineRegData.dateOfReg) + ''',' +
      // codcart
        '''' + OnlineRegData.phone + ''',' +
      // ownercart
        '''' + OnlineRegData.codecard + ''')';


    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;


Function UpdateMySQL_OnlineRegData(OnlineRegData: TOnlineRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

    ADOQuerySend.SQL.Text := 'SELECT * FROM rs_OnlineRegData WHERE idCard=''' + OnlineRegData.idCard + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ADOQuerySend.SQL.Text :=
        'INSERT INTO `rs_OnlineRegData`  (`idCard`, `dateOfReg`,`phone`,`codecard`,`rewrite`) VALUES ('
        +
      // idCard
        '''' + OnlineRegData.idCard + ''',' +
      // dateOfReg
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', OnlineRegData.dateOfReg) + ''',' +
     // phone
        '''' + OnlineRegData.phone + ''',' +
      // codecard
        '''' + OnlineRegData.codecard + ''',' +
      // rewrite
        '1' + ''')';


    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update rs_OnlineRegData set ' +
      // idCard
        '`idCard` = ''' + OnlineRegData.idCard + ''', ' +
      // phone
        '`phone` = ''' + OnlineRegData.phone + ''', ' +
      // codecard
        '`codecard` = ''' + OnlineRegData.codecard + ''', ' +
      // dateOfReg
        '`dateOfReg` = ''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', OnlineRegData.dateOfReg) + ''', ' +
      // rewrite
        '`rewrite` = 1 ' +
      // WHERE
        ' WHERE idCard  = ''' + OnlineRegData.idCard + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;


Function WriteToMySQL_PrepaymentCarWash(MoykaRecord: TPrepayment_MoykaRecord; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

      ADOQuerySend.SQL.Text :=
        'INSERT INTO `rs_prepayment_moyka`  (`idpost`,`ondate`,`money`,`rfid`) VALUES ('
        +
      // idpost
        '' + IntToStr(MoykaRecord.idpost) + ',' +
      // ondate
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now()) + ''',' +
      // money
        '''' + DecToch(FloatToStr(MoykaRecord.money)) + ''',' +
      // ownercart
        '''' + MoykaRecord.rfid + ''')';


    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;


Function UpdateMySQL_YandexRegData(YandexRegData: TYandexRegData; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

    ADOQuerySend.SQL.Text := 'SELECT * FROM yandex_registration WHERE confirm = 0 AND card_number=''' + YandexRegData.codecard + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ADOQuerySend.SQL.Text :=
        'INSERT INTO `yandex_registration`  (`phone`, `dateOfReg`,`card_number`, `card_id`,`sms_code`,`card_token`,`mask_login`,`confirm`) VALUES ('
        +
      // phone
        '''' + YandexRegData.phone + ''',' +
      // dateOfReg
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', YandexRegData.dateOfReg) + ''',' +
     // card_number
        '''' + YandexRegData.codecard + ''',' +
     // card_id
        '''' + YandexRegData.idcard + ''',' +
     // sms_code
        '''' + YandexRegData.SMSCODE + ''',' +
     // card_token
      '''' + YandexRegData.card_token + ''',' +
      // mask_login
      '''' + YandexRegData.mask_login + ''',' +
       // confirm
      '' + IntToStr(YandexRegData.confirm) + ')';

    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update yandex_registration set ' +
      // phone
        '`phone` = ''' + YandexRegData.phone + ''', ' +
      // card_number
        '`card_number` = ''' + YandexRegData.codecard + ''', ' +
      // card_id
        '`card_id` = ''' + YandexRegData.idcard + ''', ' +
      // sms_code
        '`sms_code` = ''' + YandexRegData.SMSCODE + ''', ' +
      // dateOfReg
        '`dateOfReg` = ''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', YandexRegData.dateOfReg) + ''', ' +
      // confirm
        '`confirm` = ' + IntToStr(YandexRegData.confirm) + ' , ' +
      // card_token
        '`card_token` = ''' + YandexRegData.card_token + ''', ' +
      // mask_login
        '`mask_login` = ''' + YandexRegData.mask_login + ''' ' +
      // WHERE
        ' WHERE confirm = 0 AND card_number  = ''' + YandexRegData.codecard + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;

Function WriteMySQL_yandex_transactions_bonus(YandexPurchase: TYandexPurchase; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try



      ADOQuerySend.SQL.Text :=
        'INSERT INTO `yandex_transactions_bonus`  (`orderId`, `orderExtendedId`,`stationExtendedId`, `cardNo`,`fuelId`,`cost`,`count`,`price`,`orderDateUtc`,`orderDateLocal`) VALUES ('
        +
      // orderId
        '''' + YandexPurchase.orderId + ''',' +
     // orderExtendedId
        '''' + YandexPurchase.orderExtendedId + ''',' +
     // stationExtendedId
        '''' + YandexPurchase.stationExtendedId + ''',' +
     // cardNo
        '''' + YandexPurchase.cardNo + ''',' +
     // fuelId
        '''' + YandexPurchase.fuelId + ''',' +
     // cost
        '''' + DecToch(FloatToStr(YandexPurchase.cost)) + ''',' +
     // count
        '''' + DecToch(FloatToStr(YandexPurchase.count)) + ''',' +
     // price
        '''' + DecToch(FloatToStr(YandexPurchase.price)) + ''',' +
     // orderDateUtc
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', YandexPurchase.orderDateUtc) + ''',' +
     // orderDateLocal
        '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', YandexPurchase.orderDateLocal) + ''')';

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;



Function UpdateMySQL_YandexPurchaseAnswer(YandexPurchaseAnswer: TYandexPurchaseAnswer; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  res: string;

begin

  ADOQuerySend := TFDQuery.Create(nil);
  ADOQuerySend.Connection := ADOMySQLConnection;

  try

    ADOQuerySend.SQL.Text := 'SELECT * FROM yandex_transactions_bonus WHERE orderId=''' + YandexPurchaseAnswer.orderId + ''' ';

    try
      ADOQuerySend.Open;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

    if ADOQuerySend.RecordCount = 0 then
    begin
      ErrorDescription := 'orderId '+ YandexPurchaseAnswer.orderId + ' not fount';
      result := false;
      exit;
    end
    else
    begin
      ADOQuerySend.SQL.Text := 'update yandex_transactions_bonus set ' +
      // rewrite
        '`rewrite` = ' + IntToStr(YandexPurchaseAnswer.rewrite) + ', ' +
      // bonus
        '`bonus` = ''' + DecToch(FloatToStr(YandexPurchaseAnswer.bonus)) + ''', ' +
     // purchaseId
        '`purchaseId` = ''' + YandexPurchaseAnswer.purchaseId + ''', ' +
      // errorCode
        '`errorCode` = ''' + IntToStr(YandexPurchaseAnswer.errorCode) + ''', ' +
      // errorMessage
        '`errorMessage` = ''' + YandexPurchaseAnswer.errorMessage + ''', ' +
      // rewriteDate
        '`rewriteDate` = ''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now()) + ''' ' +
      // WHERE
        ' WHERE orderId  = ''' + YandexPurchaseAnswer.orderId + ''' ';

    end;

    try
      ADOQuerySend.ExecSQL;
      result := true;
    except
      on E: Exception do
      begin
        result := false;
        ErrorDescription := E.Message;
        exit;
      end;
    end;

  finally
    ADOQuerySend.Free;
  end;



end;




Function WriteToMySQL_dc_enginefixcards_moyka(dc_enginefixcards_moyka: Tdc_enginefixcards_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  curGuid :string;
  I: Integer;
begin
      LogFile.WriteLog('Обработка dc_enginefixcards_moyka ' + dc_enginefixcards_moyka.guiddocInteger);

      ADOQuerySend := TFDQuery.Create(nil);
      ADOQuerySend.Connection := ADOMySQLConnection;
   try

      // Шапка документа
      ADOQuerySend.SQL.Text := 'SELECT * FROM dc_enginefixcards_moyka WHERE guid=''' + dc_enginefixcards_moyka.guiddoc + '''  or guid=''' + dc_enginefixcards_moyka.guiddocInteger + ''' ';

      try
        ADOQuerySend.Open;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      if ADOQuerySend.RecordCount = 0 then
      begin
          ADOQuerySend.SQL.Text := 'INSERT INTO `dc_enginefixcards_moyka`  (`idcode`,`iddate`,`guid`,`uniid`) VALUES (' +
          '''' + dc_enginefixcards_moyka.idcode + ''',' +
          '''' + dc_enginefixcards_moyka.iddate + ''',' +
          '''' + dc_enginefixcards_moyka.guiddocInteger + ''',' +
          '''' + dc_enginefixcards_moyka.uniid + ''')';
          curGuid :=  dc_enginefixcards_moyka.guiddocInteger;
      end
      else
      begin
          ADOQuerySend.First;
          curGuid := ADOQuerySend.FieldByName('guid').AsString;

          ADOQuerySend.SQL.Text := 'update dc_enginefixcards_moyka set ' +
          '`guid` = '''       + dc_enginefixcards_moyka.guiddocInteger +''', ' +
          '`iddate` = '''     + dc_enginefixcards_moyka.iddate +''', ' +
          '`idcode` = '''     + dc_enginefixcards_moyka.idcode + ''', ' +
          '`uniid` = '''      + dc_enginefixcards_moyka.uniid + ''' ' +
          ' WHERE guid  = ''' + dc_enginefixcards_moyka.guiddoc + ''' or guid=''' + dc_enginefixcards_moyka.guiddocInteger + ''' ';
      end;

      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      // Очистка регистров, команда проведения отдельным запросом
      ADOQuerySend.SQL.Text := 'DELETE FROM `tddc_enginefixcards_moyka` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_moyka` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_share` WHERE guiddoc=''' + curGuid + ''' ' + ' and typeDoc='''+'dc_enginefixcards_moyka'+''' ;';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;



      curGuid := dc_enginefixcards_moyka.guiddocInteger;

      if dc_enginefixcards_moyka.Registr then
      begin
          for I := Low(dc_enginefixcards_moyka.tddc_enginefixcards_moyka) to High(dc_enginefixcards_moyka.tddc_enginefixcards_moyka) do
          begin
              with dc_enginefixcards_moyka.tddc_enginefixcards_moyka[I] do
              begin

                ADOQuerySend.SQL.Text := 'INSERT INTO `tddc_enginefixcards_moyka`  (`card`,`bonus`,`share`,`guiddoc`) VALUES (' +
                '''' + card + ''',' +
                '' + DecToch(FloatToStr(bonus)) + ',' +
                '''' + share + ''',' +
                '''' + curGuid + ''')';
                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                 ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_moyka`  (`card`,`sum`,`guiddoc`, `dateof`) VALUES (' +
                '''' + card + ''',' +
                '' + DecToch(FloatToStr(bonus))  + ',' +
                '''' + curGuid + ''','+
                '''' + dateof + ''')';

                try
                  ADOQuerySend.ExecSQL;
                except
                  on E: Exception do
                  begin
                    ErrorDescription := E.Message;
                    exit;
                  end;
                end;

                if trim(share) <> '' then
                begin
                  ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_share`  (`card`,`share`,`value`,`date`,`typeDoc`,`guiddoc`) VALUES (' +
                  '''' + card + ''',' +
                  '''' + share + ''',' +
                  ' -' + DecToch(FloatToStr(value)) + ',' +
                  '''' + dc_enginefixcards_moyka.iddate + ''',' +
                  '''' + 'dc_enginefixcards_moyka' + ''',' +
                  '''' + curGuid + ''')';

                  try
                    ADOQuerySend.ExecSQL;
                  except
                    on E: Exception do
                    begin
                      ErrorDescription := E.Message;
                      exit;
                    end;
                  end;
                end;


              end;
          end;

      end;


   finally
     ADOQuerySend.Free;
   end;

   result := true;

end;


Function WriteToMySQL_dc_enginedebit_moyka(dc_enginedebit_moyka: Tdc_enginedebit_moyka; var ErrorDescription: AnsiString; var ADOMySQLConnection: TFDConnection): boolean;
var
  ADOQuerySend: TFDQuery;
  curGuid :string;
  I: Integer;
  bonusValue :Double;
begin
      LogFile.WriteLog('Обработка dc_enginedebit_moyka ' + dc_enginedebit_moyka.guiddocInteger);

      ADOQuerySend := TFDQuery.Create(nil);
      ADOQuerySend.Connection := ADOMySQLConnection;
   try

      // Шапка документа
      ADOQuerySend.SQL.Text := 'SELECT * FROM dc_enginedebit_moyka WHERE guid=''' + dc_enginedebit_moyka.guiddoc + '''  or guid=''' + dc_enginedebit_moyka.guiddocInteger + ''' ';

      try
        ADOQuerySend.Open;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      if ADOQuerySend.RecordCount = 0 then
      begin
          ADOQuerySend.SQL.Text := 'INSERT INTO `dc_enginedebit_moyka`  (`idcode`,`iddate`,`guid`,`engine`,`datecreate`,`comment`) VALUES (' +
          '''' + dc_enginedebit_moyka.idcode + ''',' +
          '''' + dc_enginedebit_moyka.iddate + ''',' +
          '''' + dc_enginedebit_moyka.guiddocInteger + ''',' +
          '' + BoolToIntSTR(dc_enginedebit_moyka.Registr) + ',' +
          '''' + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now())  + ''',' +
          '''' + dc_enginedebit_moyka.comment + ''')';
          curGuid :=  dc_enginedebit_moyka.guiddocInteger;
      end
      else
      begin
          ADOQuerySend.First;
          curGuid := ADOQuerySend.FieldByName('guid').AsString;

          ADOQuerySend.SQL.Text := 'update dc_enginedebit_moyka set ' +
          '`guid` = '''       + dc_enginedebit_moyka.guiddocInteger +''', ' +
          '`iddate` = '''     + dc_enginedebit_moyka.iddate +''', ' +
          '`idcode` = '''     + dc_enginedebit_moyka.idcode + ''', ' +
          '`engine` = '       + BoolToIntSTR(dc_enginedebit_moyka.Registr) +', ' +
          '`datecreate` = '''  + FormatDateTime('yyyy-mm-dd hh:mm:ss', Now()) +''', ' +
          '`comment` = '''      + dc_enginedebit_moyka.comment + ''' ' +
          ' WHERE guid  = ''' + dc_enginedebit_moyka.guiddoc + ''' or guid=''' + dc_enginedebit_moyka.guiddocInteger + ''' ';
      end;

      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;


      // Очистка регистров, команда проведения отдельным запросом

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_moyka` WHERE guiddoc=''' + curGuid + ''' ';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;

      ADOQuerySend.SQL.Text := 'DELETE FROM `rn_cardsnakp_share` WHERE guiddoc=''' + curGuid + ''' ' + ' and typeDoc='''+'dc_enginedebit_moyka'+''' ;';
      try
        ADOQuerySend.ExecSQL;
      except
        on E: Exception do
        begin
          ErrorDescription := E.Message;
          exit;
        end;
      end;



      curGuid := dc_enginedebit_moyka.guiddocInteger;

      if dc_enginedebit_moyka.Registr then
      begin
          for I := Low(dc_enginedebit_moyka.tddc_enginedebit_moyka) to High(dc_enginedebit_moyka.tddc_enginedebit_moyka) do
          begin
              with dc_enginedebit_moyka.tddc_enginedebit_moyka[I] do
              begin


                if bonusDebit > 0 then
                begin
                  bonusDebit :=  -bonusDebit;

                  ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_moyka`  (`card`,`sum`,`guiddoc`, `dateof`) VALUES (' +
                  '''' + card + ''',' +
                  '' + DecToch(FloatToStr(bonusDebit))  + ',' +
                  '''' + curGuid + ''','+
                  '''' + dateof + ''')';

                  try
                    ADOQuerySend.ExecSQL;
                  except
                    on E: Exception do
                    begin
                      ErrorDescription := E.Message;
                      exit;
                    end;
                  end;
                end;

                if bonusCredit > 0 then
                begin
                  bonusDebit :=  bonusCredit;

                  ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_moyka`  (`card`,`sum`,`guiddoc`, `dateof`) VALUES (' +
                  '''' + card + ''',' +
                  '' + DecToch(FloatToStr(bonusDebit))  + ',' +
                  '''' + curGuid + ''','+
                  '''' + dateof + ''')';

                  try
                    ADOQuerySend.ExecSQL;
                  except
                    on E: Exception do
                    begin
                      ErrorDescription := E.Message;
                      exit;
                    end;
                  end;
                end;

                if trim(share) <> '' then
                begin
                  ADOQuerySend.SQL.Text := 'INSERT INTO `rn_cardsnakp_share`  (`card`,`share`,`value`,`date`,`typeDoc`,`guiddoc`) VALUES (' +
                  '''' + card + ''',' +
                  '''' + share + ''',' +
                  ' -' + DecToch(FloatToStr(value)) + ',' +
                  '''' + dateof + ''',' +
                  '''' + 'dc_enginedebit_moyka' + ''',' +
                  '''' + curGuid + ''')';

                  try
                    ADOQuerySend.ExecSQL;
                  except
                    on E: Exception do
                    begin
                      ErrorDescription := E.Message;
                      exit;
                    end;
                  end;
                end;

              end;

          end;

      end;


   finally
     ADOQuerySend.Free;
   end;

   result := true;

end;


end.
