object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Default = True
      Name = 'DefaultHandler'
      PathInfo = '/'
      OnAction = WebModule1DefaultHandlerAction
    end>
  BeforeDispatch = WebModuleBeforeDispatch
  AfterDispatch = WebModuleAfterDispatch
  Height = 333
  Width = 414
  object DSServer1: TDSServer
    OnError = DSServer1Error
    Left = 320
    Top = 19
  end
  object DSHTTPWebDispatcher1: TDSHTTPWebDispatcher
    DSContext = 'json/'
    RESTContext = 'v1/'
    Server = DSServer1
    Filters = <>
    AuthenticationManager = DSAuthenticationManager1
    OnFormatResult = DSHTTPWebDispatcher1FormatResult
    WebDispatch.PathInfo = 'json*'
    Left = 280
    Top = 259
  end
  object WebFileDispatcher1: TWebFileDispatcher
    WebFileExtensions = <
      item
        MimeType = 'text/css'
        Extensions = 'css'
      end
      item
        MimeType = 'text/javascript'
        Extensions = 'js'
      end
      item
        MimeType = 'image/x-png'
        Extensions = 'png'
      end
      item
        MimeType = 'text/html'
        Extensions = 'htm;html'
      end
      item
        MimeType = 'image/jpeg'
        Extensions = 'jpg;jpeg;jpe'
      end
      item
        MimeType = 'image/gif'
        Extensions = 'gif'
      end>
    BeforeDispatch = WebFileDispatcher1BeforeDispatch
    WebDirectories = <
      item
        DirectoryAction = dirInclude
        DirectoryMask = '*'
      end
      item
        DirectoryAction = dirExclude
        DirectoryMask = '\templates\*'
      end>
    RootDirectory = '.'
    VirtualPath = '/'
    Left = 160
    Top = 224
  end
  object DSProxyGenerator1: TDSProxyGenerator
    ExcludeClasses = 'DSMetadata'
    MetaDataProvider = DSServerMetaDataProvider1
    Writer = 'Java Script REST'
    Left = 48
    Top = 248
  end
  object DSServerMetaDataProvider1: TDSServerMetaDataProvider
    Server = DSServer1
    Left = 32
    Top = 144
  end
  object DSClassMobile: TDSServerClass
    OnGetClass = DSClassMobileGetClass
    Server = DSServer1
    Left = 48
    Top = 64
  end
  object DSAuthenticationManager1: TDSAuthenticationManager
    OnUserAuthenticate = DSAuthenticationManager1UserAuthenticate
    OnUserAuthorize = DSAuthenticationManager1UserAuthorize
    Roles = <
      item
        AuthorizedRoles.Strings = (
          'admin')
        DeniedRoles.Strings = (
          'NotRegistred')
        ApplyTo.Strings = (
          'admin')
        Exclude.Strings = (
          'admin')
      end>
    Left = 328
    Top = 184
  end
  object DSClassRest1s: TDSServerClass
    OnGetClass = DSClassRest1sGetClass
    Server = DSServer1
    Left = 120
    Top = 64
  end
  object DSClassYandex: TDSServerClass
    OnGetClass = DSClassYandexGetClass
    Server = DSServer1
    Left = 184
    Top = 64
  end
  object DSServerMetaDataProvider2: TDSServerMetaDataProvider
    Left = 160
    Top = 144
  end
  object DSClassTerminal: TDSServerClass
    OnGetClass = DSClassTerminalGetClass
    Server = DSServer1
    Left = 248
    Top = 64
  end
end
