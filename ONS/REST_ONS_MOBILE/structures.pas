unit structures;

interface

type

 TClientMySQLSet = record
    ServerAdress: string;
    Login: string;
    Uinpromt: string;
    Port: string;
    DataBase: string;
    ConnectionString: string;
    enabled: boolean;
  end;

 TSettingProgram = record
    PortHTTP: Integer;
    LoginWeb: string;
    PassWeb: string;

    PassWordMySQL: string;
    ServerAdressMySQL: string;
    LoginMySQL: string;
    DataBaseMySQL: string;
    PortMySQL: string;
    IdDeviceMySQL: Integer;
    CaptionMainForm: string;
    EnabledUpdateWebSuit: boolean;

    ServerAdressFTPSecurity: string;
    LoginFTPSecurity: string;
    PassWordFTPSecurity: string;
    PortFTPSecurity: Integer;
    EnabledFTPSecurity: boolean;
    OnLineLogConnected:Boolean;
    AutoRun:Boolean;
    RegNum:Boolean;

    YandexEnabled:boolean;
    YandexServerBD:string;
    YandexNameBD:string;
    YandexLoginBD:string;
    YandexPassBD:string;
    YandexPortBD:string;
    YandexAPI:string;
    YandexProductionAPI:boolean;
    YandexActualTime:Integer;

    SMSServer:string;
    SMSLogin:string;
    SMSPass:string;

  end;

  TRateBonusCard = record
    BarCode: string[50];
    idGoods: string[20];
    idShop: string[20];
    BonusRate: Double;
    ActionId: integer;
    extCodeAction: string[20];
    AmtSale: Double;
    CntSale: Double;
    AmtBonus: Double;
    AmtAction: Double;
  end;

  TinfoOilCard = record
    id: integer;
    codcard:string;
    guid: string;
    guid_contract: string;
    guidClient:string;
    NameClient: string[50];
    AllowUse: boolean;
    PinCode: String[50];
    AllOK: boolean;
    Price1C: Double;
    ErrorDescription: string[50];
    periodlimit: byte;
    typelimit: byte;
    typeClient: byte;
    dateonlimit: TDateTime;
    idcode: string[50];
    ownercard: string[50];
    liter: Double;
    suma: Double;
    limitmany: Double;
    limitfuel: Double;
    typeCard: byte;
    Discont: Double;
    limitMoyka: integer;
    Moyka: Double;
    balance:Double;
    credit:Double;
    balanceControl:integer;
    balanceActualdate:TDateTime;
    Locked:boolean;
    ostMoykaAction: Double;
  end;


  TTransactionMoyka = record
    RFID:string;
    device_id:string;
    sum:Double;
    errcode:integer;
    oper_id:integer;
    description: string;
  end;

  TBalanceCorpDiscount = record
    guid_fuel:integer;
    guid_card:integer;
    date_query: string[30];
    BarCode: string[50];
    idGoods: string[20];
    idCard: string[20];
    Balance: Double;
    date:TDateTime;
  end;


  TJurParner = record
    dateCreate:TDateTime;
    codeCard:string;
    codePartner:string;
    amount:Double;
  end;

  TJurParnerList = array of TJurParner;

  TinfoBonuxCard = record
    NameClient: string[50];
    idCodeCard: string;
    barcode: string;
    rfid: string;
    OstBonus: Double;
    OstMoyka: Double;
    SumDeb: Double;
    Discont: Double;
    ActionId: integer;
    ActionIdBonusRate: integer;
    guiddocaction: integer;
    BonusRate: Double;
    LitersFuelMonth: Double;
    SumFuelMonth: Double;
    LitersFuelYear: Double;
    SumFuelYear: Double;
  end;

  TInfoPersone = record
    phone:string;
    idCode:string;
    idGroup:AnsiString;
    name:string;
    f:string;
    i:string;
    o:string;
    Email:string;
    birthday:TDateTime;
    sex:string;
    changed:boolean;
    guid: string;
    toWrite:integer;
    ReferralCode:integer;
    ReferralCodeInvitation:integer;
  end;
  TPersonList = array of TInfoPersone;

  TPersoneAddInfo = record
    idCode:string;
    codecard:string;
    phone:string;
    Email:string;
    sendReceipt:Integer;
    CityOfResidence:string;
    rewrite:integer;
    ReferralCodeInvitation:integer;
  end;

  TPersoneAddInfoList = array of TPersoneAddInfo;


  TRecordTransactionOfCard = packed record
     idcart:AnsiString;
     typeDoc:AnsiString;
     guidDoc:AnsiString;
     datetime:TDateTime;
     nameShop:AnsiString;
     value:Double;
  end;

  TTransactionLogOfCard = array of TRecordTransactionOfCard;
  PTransactionLogOfCard = ^TTransactionLogOfCard;


  TRecordTransactionLog = packed record
     datedoc:TDateTime;
     numberdoc:AnsiString;
     idcard:AnsiString;
     idshop:AnsiString;
     guiddoc:AnsiString;
     guidreceipt:AnsiString;
     idgood:AnsiString;
     quantity:Double;
     Price:Double;
     sumsale:Double;
     sumbonus:Double;
     codecard:AnsiString;
     namegood:AnsiString;
     fullnamegood:AnsiString;
     BasePrice:Double;

  end;

  TTransactionLog = array of TRecordTransactionLog;
  PTransactionLog = ^TTransactionLog;

  TRecordCardList = record
    idOwner:AnsiString;
    phone:AnsiString;
    f:AnsiString;
    i:AnsiString;
    o:AnsiString;
    Email:AnsiString;
    birthday:TDateTime;
    idCard:AnsiString;
    codeCard:AnsiString;
    dateOfUse:TDateTime;
    sendReceipt:Integer;
    ReferralCode:Integer;
    ReferralCodeInvitation:Integer;

  end;

  TCardList = array of TRecordCardList;
  PCardList = ^TCardList;

  TBonusRateRecord = record
    NameGoods:AnsiString;
    idCoogs:AnsiString;
    downAmt:Double;
    upAmt:Double;
    rate:Double;
    periodType:integer;
    periodStr:string;
  end;

  TBonusRateTable = array of TBonusRateRecord;




  Ttbdc_MoykaRecord = record
    guiddoc:string;
    guiddocInteger:string;
    card:string;
    moyka:Double;
    bonus:Double;
  end;

  Ttbdc_Moyka = array of Ttbdc_MoykaRecord;

  Tdc_engine_pay_moyka = record
    Registr   :Boolean;
    guiddoc   :string;
    guiddocInteger :string;
    idcode    :string;
    iddate    :string;
    comment   :AnsiString;
    count_tbdc_Moyka : Integer;
    tbdc_Moyka :Ttbdc_Moyka;
  end;


 Ttbdc_enginecardnacRecord = record
    guiddoc:string;
    guiddocInteger:string;
    iddoc:string;
    date:string;
    card:string;
    goods:string;
    quantity:Double;
    sum:Double;
    bonus:Double;
    actionextcode:string;
  end;

  Ttbdc_enginecardnac = array of Ttbdc_enginecardnacRecord;


  Ttbdc_enginecardspisRecord = record
    guiddoc:string;
    guiddocInteger:string;
    iddoc:string;
    date:string;
    card:string;
    goods:string;
    quantity:Double;
    bonus:Double;
  end;

  Ttbdc_enginecardspis = array of Ttbdc_enginecardspisRecord;

  Ttbdc_enginecards_shareRecord = record
    guiddoc:string;
    guiddocInteger:string;
    iddoc:string;
    date:string;
    card:string;
    goods:string;
    share:string;
    value:Double;
  end;

  Ttbdc_enginecards_share = array of Ttbdc_enginecards_shareRecord;

  Tdc_enginecards = record
    Registr   :Boolean;
    guiddoc   :string;
    guiddocInteger :string;
    uniid:string;
    idcode    :string;
    iddate    :string;
    datecreate :string;
    card :string;
    shop :string;
    comment   :AnsiString;

    count_tbdc_enginecardnac : Integer;
    tbdc_enginecardnac :Ttbdc_enginecardnac;

    count_tbdc_enginecardspis : Integer;
    tbdc_enginecardspis :Ttbdc_enginecardspis;

    count_tbdc_enginecards_share : Integer;
    tbdc_enginecards_share :Ttbdc_enginecards_share;


  end;

  TInfoGoods = record
    idCode:string;
    idGroup:string;
    idName:string;
    fullName:string;
    article:string;
    unitCode:string;
    nds:integer;
    level:integer;
    is_service:integer;
    is_fuel:integer;
    is_tobacco:integer;
    guid:integer;
  end;

  TInfoGroupGoods = record
    idCode:string;
    idGroup:string;
    idName:string;
    level:integer;
    guid:integer;
  end;

   // РАЗОВОЕ НАЧИСЛЕНИЕ БОНУСОВ

  Ttbdc_enginefixcards_Record = record
    guiddoc:string;
    guiddocInteger:string;
    card:string;
    bonus:Double;
    dateOf:string;
    iddoc    :string;
  end;

  Ttddc_enginefixcards = array of Ttbdc_enginefixcards_Record;

  Tdc_enginefixcards = record
    Registr   :Boolean;
    guiddoc   :string;
    guiddocInteger :string;
    uniid:string;
    idcode    :string;
    iddate    :string;
    comment   :AnsiString;

    count_tddc_enginefixcards : Integer;
    tddc_enginefixcards :Ttddc_enginefixcards;

  end;

  // РАЗОВОЕ НАЧИСЛЕНИЕ БОНУСОВ МОЙКА

  Ttbdc_enginefixcards_moyka_Record = record
    guiddoc:string;
    guiddocInteger:string;
    card:string;
    bonus:Double;
    value:Double;
    share:string;
    dateOf:string;
  end;

  Ttddc_enginefixcards_moyka = array of Ttbdc_enginefixcards_moyka_Record;



  Tdc_enginefixcards_moyka = record
    Registr   :Boolean;
    guiddoc   :string;
    guiddocInteger :string;
    uniid:string;
    idcode    :string;
    iddate    :string;
    comment   :AnsiString;

    count_tddc_enginefixcards_moyka : Integer;
    tddc_enginefixcards_moyka :Ttddc_enginefixcards_moyka;

  end;

  // СПИСАНИЕ БОНУСОВ МОЙКА

  Ttddc_enginedebit_moyka_Record = record
    guiddoc:string;
    guiddocInteger:string;
    card:string;
    bonusDebit:Double;
    bonusCredit:Double;
    share:string;
    value:Double;
    dateOf:string;
  end;

  Ttddc_enginedebit_moyka = array of Ttddc_enginedebit_moyka_Record;

  Tdc_enginedebit_moyka = record
    Registr   :Boolean;
    guiddoc   :string;
    guiddocInteger :string;
    idcode    :string;
    iddate    :string;
    comment   :AnsiString;

    count_tddc_enginedebit_moyka : Integer;
    tddc_enginedebit_moyka:Ttddc_enginedebit_moyka;

  end;

  // КАРТА КЛИЕНТА
  TCard = record
    idcode:AnsiString;
    idname:AnsiString;
    idgroup:AnsiString;
    codecard:AnsiString;
    rfid:AnsiString;
    ownercart:AnsiString;
    level:AnsiString;
    guid:AnsiString;
    isOnlineReg:Integer;

    NameClient: string[50];
    PinCode: String[50];

    periodlimit: byte;
    typelimit: byte;
    typeClient: byte;
    dateonlimit: TDateTime;
    limitmany: Double;
    limitfuel: Double;
    typeCard: byte;
    Discont: Double;
    limitMoyka: Double;
    toWrite:integer;

  end;
 TPersonCardList = array of TCard;

  TOnlineRegData = record
    idCard:AnsiString;
    dateOfReg:TDateTime;
    phone:String;
    codecard:String;
  end;


  TOnlineRegDataList = array of TOnlineRegData;

  TPrepayment_MoykaRecord = record
    id:Integer;
    idpost:Integer;
    ondate:TDateTime;
    money:Integer;
    rfid:AnsiString;
  end;

  TYandexRegData = record
    dateOfReg:TDateTime;
    phone:String;
    card_token:String;
    codecard:String;
    idcard:String;
    SMSCODE:string;
    confirm:Integer;
    mask_login:string;

  end;

  TYandexPurchase = record
    cardNo:String;  //Номер карты strin
    orderId:String; // ID заказа со стороны ЯЗЛ
    orderExtendedId:String; //ID заказа со стороны АСУ Партнёра (если был передан)
    stationExtendedId:String;  //ID станции Партнёра
    fuelId:String; //Код топлива
    cost:Double; // Итого оплачено в АЗС
    count:Double; // Кол-во литров
    price:Double; // Цена за литр
    orderDateUtc:TDateTime; // Дата создания заказа (UTC)
    orderDateLocal:TDateTime; // Дата создания заказа, которая пришла от АСУ
  end;

  TYandexPurchaseList = array of TYandexPurchase;

  TYandexPurchaseAnswer = record
    rewrite:integer;
    orderId:String; // ID заказа со стороны ЯЗЛ
    purchaseId:String;  //Номер транзакции
    bonus:Double;       // Начисленно бонусов
    errorCode:integer;
    errorMessage:AnsiString;
    userErrorMessage:AnsiString;

  end;

    TRecordPaymentMoykaTotal = packed record
     iddevice:AnsiString;
     TotalMoney:Double;
     NotCheckMoney:Double;
     isBank:integer;

  end;

  TPaymentMoykaTotal = array of TRecordPaymentMoykaTotal;

  TRecordPaymentMoykaList = packed record
    id:integer;
    iddevice:AnsiString;
    dateadd:TDateTime;
    money:Double;
    check:integer;
    isBank:integer;
  end;

  TPaymentMoykaList = array of TRecordPaymentMoykaList;

  TSalesByBonusCardRecord = record
    codeCard:AnsiString;
    guidDoc:AnsiString;
    downAmt:Double;
    upAmt:Double;
    rate:Double;
    periodType:integer;
    periodStr:string;
  end;

  TSalesByBonusCardList = array of TSalesByBonusCardRecord;

  TsalesBonusCard = record
    idCodeCard: string;
    barcode: string;

    quantityFuel: Double;
    sumFuel: Double;
    quantityService: Double;
    sumService: Double;
    quantityTobacco: Double;
    sumTobacco: Double;
    quantityGoods: Double;
    sumGoods: Double;

  end;

 TsalesBonusCardList = array of TsalesBonusCard;


  TBirthdayCard = record
    birthday: TDateTime;
    codecard: string;
    namePerson: string;
    idCard:string;
  end;

 TBirthdayCardList = array of TBirthdayCard;

  const
    dirSecurityFiles:string = '\UpLoadSecurity';
    dirReceiptFiles:string = '\ReceiptFiles';

implementation

end.
