* ConstDefines.h

#INCLUDE Excel.h
#INCLUDE Word.h
#INCLUDE Processes.h
#INCLUDE Dvapi32.h

* Argus table reservations
#define DLL_WPFTABLERES_REQUIRED_VERSION	"1.15"

* String constants
#define CRLF				CHR(13)+CHR(10)
#define VIRTUAL_ROOMNUM		"?@@?"

* Numeric constants
#define MAX_BILL_WINDOW		9999

#define AddressTable		(gcDatadir+"address")&&		&& Name of Param Table
#define AddressTAlias		Address&&					&& Alias of Param Table
#define ParamTable			(gcDatadir+"Param")&&		&& Name of Param Table
#define ParamTAlias			Param&&						&& Alias of Param Table
#define RoomPlanTable		(gcDatadir+"Roomplan")&& 	&& Name of Roomplan Table
#define RoomPlanTAlias		Roomplan&&					&& Alias of Roomplan Table
#define ReservationsTable	(gcDatadir+"Reservat")&&	&& Name of Rezervations Table
#define ReservationsTAlias	Reservat&&					&& Alias of Rezervations Table
#define RoomTable			(gcDatadir+"Room")&&		&& Name of Room Table
#define RoomTAlias			Room&&						&& Alias of Room Table
#define RoomTypeTable		(gcDatadir+"RoomType")&&	&& Name of Room Type Table
#define RoomTypeTAlias		RoomType&&					&& Alias of Room Type Table
#define OutOfOrderTable		(gcDatadir+"Outoford")&&	&& Name of OutOfOrd Table
#define OutOfOrderTAlias	Outoford&&					&& Alias of OutOfOrd Table
#define SeasonsTable		(gcDatadir+"Season")&&		&& Name of Season Table
#define SeasonsTAlias		Season&&					&& Alias of Season Table
#define PayMethodTable		(gcDatadir+"Paymetho")&&	&& Name of Budget Table
#define PayMethodTAlias		Paymetho&&					&& Alias of Budget Table
#define BudgetTable			(gcDatadir+"Budget")&&		&& Name of Budget Table
#define BudgetTAlias		Budget&&					&& Alias of Budget Table
#define PickListTable		(gcDatadir+"PickList")&&	&& Name of PickList Table
#define PickListTAlias		PickList&&					&& Alias of PickList Table
#define RatecodeTable		(gcDatadir+"Ratecode")&&	&& Name of Budget Table
#define RatecodeTAlias		Ratecode&&					&& Alias of Budget Table
#define RoomFeatTable		(gcDatadir+"Roomfeat")&&	&& Name of RoomFeat Table
#define RoomFeatTAlias		Roomfeat&&					&& Alias of RoomFeat Table
#define TitleTable			(gcDatadir+"Title")&&		&& Name of Title Table
#define TitleTAlias			Title&&						&& Alias of Title Table
#define ArticleTable		(gcDatadir+"Article")&&		&& Name of Article Table
#define ArticleTAlias		Article&&					&& Alias of Article Table
#define PrtypesTable		(gcDatadir+"Prtypes")&&		&& Name of Prtypes Table
#define PrtypesTAlias		Prtypes&&					&& Alias of Prtypes Table
#define ApartnerTable		(gcDatadir+"Apartner")&&	&& Name of Apartner Table
#define ApartnerTAlias		Apartner&&					&& Alias of Apartner Table
#define HistresTable		(gcDatadir+"Histres")&&		&& Name of Histres Table
#define HistresTAlias		Histres&&					&& Alias of Histres Table
#define AvailTable			(gcDatadir+"Availab")&&		&& Name of Availab Table
#define AvailTAlias			Availab&&					&& Alias of Availab Table
#define PostTable			(gcDatadir+"Post")&&		&& Name of Post Table
#define PostTAlias			Post&&						&& Alias of Post Table
#define IDTable				(gcDatadir+"ID")&&			&& Name of ID Table
#define IDTAlias			ID&&						&& Alias of ID Table
#define HistpostTable		(gcDatadir+"Histpost")&&	&& Name of Histpost Table
#define HistpostTAlias		Histpost&&					&& Alias of Histpost Table
#define ZipcodeTable		(gcDatadir+"Zipcode")&&		&& Name of Zipcode Table
#define ZipcodeTAlias		Zipcode&&					&& Alias of Zipcode Table
#define LedgpostTable		(gcDatadir+"Ledgpost")&&	&& Name of Budget Table
#define LedgpostTAlias		Ledgpost&&					&& Alias of Budget Table
#define VoucherTable		(gcDatadir+"Voucher")&&		&& Name of Budget Table
#define VoucherTAlias		Voucher&&					&& Alias of Budget Table
#define AracctTable			(gcDatadir+"Aracct")&&		&& Name of Budget Table
#define AracctTAlias		Aracct&&					&& Alias of Budget Table
#define ActionTable			(gcDatadir+"Action")&&		&& Name of Budget Table
#define ActionTAlias		Action&&					&& Alias of Budget Table
#define DocumentTable		(gcDatadir+"Document")&&	&& Name of Budget Table
#define DocumentTAlias		Document&&					&& Alias of Budget Table
#define PeriodTable			(gcDatadir+"Period")&&		&& Name of Period Table
#define PeriodTAlias		Period&&					&& Alias of Period Table
#define CashierTable		(gcDatadir+"Cashier")&&		&& Name of Cashier Table
#define CashierTAlias		Cashier&&					&& Alias of Cashier Table
#define RateartiTable		(gcDatadir+"Ratearti")&&	&& Name of Ratearti Table
#define RateartiTAlias		Ratearti&&					&& Alias of Ratearti Table
#define GroupTable			(gcDatadir+"Group")&&		&& Name of Group Table
#define GroupTAlias			Group&&						&& Alias of Group Table
#define UserTable			(gcDatadir+"User")&&		&& Name of User Table
#define UserTAlias			User&&						&& Alias of User Table
#define ListsTable			(gcDatadir+"Lists")&&		&& Name of Lists Table
#define ListsTAlias			Lists&&						&& Alias of Lists Table
#define AllottTable			(gcDatadir+"Allott")&&		&& Name of Allott Table
#define AllottTAlias		Allott&&					&& Alias of Allott Table
#define AltHeadTable		(gcDatadir+"AltHead")&&		&& Name of AltHead Table
#define AltHeadTAlias		AltHead&&					&& Alias of AltHead Table
#define AltSplitTable		(gcDatadir+"AltSplit")&&	&& Name of AltSplit Table
#define AltSplitTAlias		AltSplit&&					&& Alias of AltSplit Table
#define CompanyTable		AddressTable&&				&& Name of Company Table
#define CompanyTAlias		AddressTAlias&&				&& Alias of Company Table
#define ledgpaymtable		(gcDatadir+"ledgpaym")&&	&& Name of ledger
#define ledgpaymtalias		ledgpaym&&					&& Alias of ledger
#define arposttable			(gcDatadir+"arpost")&&		&& Name of ledger
#define arposttalias		arpost&&					&& Alias of ledger
#define deposittable		(gcDatadir+"deposit")&&		&& Name of ledger
#define deposittalias		deposit&&					&& Alias of ledger


#define GetLangText GetLangText&&			&& Function that search *Language Table. For LangVar = "DE" Text("PLAN","TXT_CLOCE") returns "Schliessen"


#define ReserStep		0.1&&				&& 24.100, 24.200, 24.300, ......, 24.900
*#define ReserStep		0.01&&				&& 24.010, 24.020, 24.030, ......, 24.990
*#define ReserStep		0.001&&				&& 24.001, 24.002, 24.003, ......, 24.999

#define ShKCChoose		12&&				&& Key code of Choose Shortcut
#define ShSCAChoose		2&&					&& ShiftCtrlAlt of Choose Shortcut

#define ShKCNewRes		14&&				&& Key code of New Reservation Shortcut
#define ShSCANewRes		2&&					&& ShiftCtrlAlt of New Reservation Shortcut

#define ShKCChgRes		5&&					&& Key code of Change Reservation Shortcut
#define ShSCAChgRes		2&&					&& ShiftCtrlAlt of Change Reservation Shortcut

#define ShKArtKey		25&&
#define ShSACArtKey		2&&

#define ShKOOONote		9&&
#define ShSACOOONote	2&&

#define ShKPayMDep		15&&
#define ShSACPayMDep	2&&

#define ShKPayMKey		25&&
#define ShSACPayMKey	2&&

#define ShKRatCSplit	12&&
#define ShSACRatCSplit	2&&

#define ShKRepGo		20&&
#define ShSACRepGo		2&&

#define ShKRepMod		13&&
#define ShSACRepMod		2&&

#define ShKRepExp		24&&
#define ShSACRepExp		2&&

#define ShKRepInp		9&&
#define ShSACRepInp		2&&

#define ShKRepSQL		17&&
#define ShSACRepSQL		2&&

#define ShKRepTxt		12&&
#define ShSACRepTxt		2&&

#define ShKRNumFeat		20&&
#define ShSACRNumFeat	2&&

#define ShKUGrMen		18&&
#define ShSACUGrMen		2&&

#define ShKUGrBt		2&&
#define ShSACUGrBt		2&&

*#define 		10&&
*#define 		2&&

*#define 		10&&
*#define 		2&&

*#define 		10&&
*#define 		2&&



#define EDIT_MODE			1&&				&& Constants for menager mode
#define NEW_MODE			2&&
#define COPY_MODE			3&&
#define DELETE_MODE			4&&
#define READONLY_MODE		5&&

#define TITLE_FORM			1&&				&& Identifies TitleForm in formset
#define RTYPE_FORM			2&&				&& Identifies RoomTypeForm in formset
#define ARTICLE_FORM		3&&				&& Identifies ArticleForm in formset
#define ROOMNUM_FORM		4&&				&& Identifies RoomNumForm in formset
#define RATEC_FORM			5&&				&& Identifies RateCodeForm in formset
#define RATEARTI_FORM		6&&				&& Identifies RateArtiForm in formset
#define USER_FORM			7&&				&& Identifies UserForm in formset
#define OOO_FORM			8&&				&& Identifies OOOForm in formset
#define ALLOTT_FORM			9&&				&& Identifies AllottForm in formset
#define ALLOTT_SEARCH_FORM	10&&			&& Identifies AllottSearchForm in formset
#define FULL_RATEC_FORM		11&&			&& Identifies FullRateCForm in formset
#define RATEC_SEARCH_FORM	12&&			&& Identifies RateCSearchForm in formset
#define ZOOM_IN_FORM		14&&			&& Identifies ZoomInForm in formset

#define BaseBkGridRowColor1	RGB(255,255,255)
#define BaseBkGridRowColor2	RGB(251,251,251)
#define BaseBkGridRowColor3	RGB(247,247,247)
#define BaseBkGridRowColor4	RGB(243,243,243)
#define BaseBkGridRowColor5	RGB(239,239,239)
#define BaseBkGridRowColor6	RGB(235,235,235)
#define BaseBkGridRowColor7	RGB(231,231,231)

#define BaseBkTermColor			RGB(200,255,255)
#define BaseBkTermChangeColor	RGB(255,128,64)

#define BaseBk6PMColor			RGB(128, 0, 0)
#define BaseFr6PMColor			RGB(255,255,255)

#define BaseBkAssignColor		RGB(0,0,255)
#define BaseFrAssignColor		RGB(255,255,255)

#define BaseBkDeffiniteColor	RGB(255,0,0)
#define BaseFrDeffiniteColor	RGB(0,0,0)

#define BaseBkInColor			RGB(255,255,255)
#define BaseFrInColor			RGB(0,0,0)

#define BaseBkOutColor			RGB(0,0,0)
#define BaseFrOutColor			RGB(255,255,255)

#define BaseBkOptionColor		RGB(0,255,255)
#define BaseFrOptionColor		RGB(0,0,0)

#define BaseBkWaitingColor		RGB(255,0,255)
#define BaseFrWaitingColor		RGB(0,0,0)

#define BaseBkTENColor			RGB(192,192,192)	&& RGB(255,0,255)
#define BaseFrTENColor			RGB(0,0,0)

#define BaseBkCanceledColor		RGB(0,255,0)
#define BaseFrCanceledColor		RGB(0,0,0)

#define BaseBkNoShowColor		RGB(0,255,0)
#define BaseFrNoShowColor		RGB(0,0,0)

#define BaseBkOOOColor			RGB(255,255,0)
#define BaseFrOOOColor			RGB(0,0,0)

#define BaseBkOOSColor			RGB(255,255,0)
#define BaseFrOOSColor			RGB(0,0,0)

#define BaseBkBkgColor			RGB(0, 255, 0)
#define BaseFrBkgColor			RGB(0, 255, 0)
#define BaseLinesColor			RGB(192,192,192)
#define BaseIntSelColor			RGB(255,128,64)

#define BaseDayLines			RGB(128,128,128)
#define BaseNoonLines			RGB(192,192,192)
#define BaseEventStartEnd		RGB(255,193,193)
#define BasePosLnColor			RGB(255,255,0)

*Room status circle fillcolors
#define BaseRmStClnColor		RGB(130,250,190)
#define BaseRmStDirColor		RGB(250,120,190)
#define BaseRmStOOOColor		RGB(250,240,150)
#define BaseRmStOOSColor		RGB(150,190,250)

#define ADR_INT_SIGN	"%ADRINT%"
#define ADR_INT_GUEST	"%ADRINTGUEST%"
#define ADR_INT_DATES	"%ADRINTDATE%"

*For BillForm - codes of menu comands
#define BILL_EDIT_COMMAND		 1
#define BILL_POST_COMMAND		 2
#define BILL_PAY_COMMAND		 3
#define BILL_DELETE_COMMAND		 4
#define BILL_MARK_COMMAND		 5
#define BILL_INSERT_COMMAND		 6
#define BILL_SPLIT_COMMAND		 7
#define BILL_PRINT_COMMAND		 8
#define BILL_PRINTALL_COMMAND	 9
#define BILL_PREVIEW_COMMAND	10
#define BILL_CHECKOUT_COMMAND	11
#define BILL_REDIRECT_COMMAND	12
#define BILL_INTERFACE_COMMAND	13
#define BILL_FORMAT_COMMAND		14
#define BILL_GROUP_COMMAND		15
#define BILL_CLOSE_COMMAND		16

*For ResrateForm - codes for edit modes
#define STANDARD_RESRATE			1
#define REVERT_TO_NON_MANUAL_STATE	2
#define ONLY_CHANGE_PAID_ROOM		3

*For ResrateForm - colors
#define COLOR_DEFAULT			0x000000	&& RGB(0,0,0)
#define COLOR_SYSDATE			0x008000	&& RGB(0,128,0)
#define COLOR_POSTED			0x000080	&& RGB(128,0,0)
#define COLOR_LINKED			0x808080	&& RGB(128,128,128)
#define COLOR_INVALID			0x0000FF	&& RGB(255,0,0)

*For BillForm - codes of returning values
#define BILL_CANCEL				0
#define BILL_REFRESH_ONE		1
#define BILL_REFRESH_ALL		2

*for ConferenceForm
#define SHOW_PAST				5&&		&& - how many days in the past is shown
#define SHOW_FUTURE				200&&	&& - how many days in the future is shown

*for ConferenceDayForm
#define CONF_DAY_TIME_PERIODS	12&&						&& - time lines in Conf day form
#define CONF_DAY_START_TIME		(param.pa_starthr * 60)&&	&& - start time in minutes in Conf day form
#define CONF_DAY_SHOW_TIME		1440&&						&& - time period in minutes in Conf day form

#define MIN_RESER_WIDTH			15&&	&& - minimal width of reservations in minutes

#define TEXT_MSG				1&&		&& - code for text message
#define LOG_OFF_MSG				2&&		&& - code for log off message
#define TEXT_MSG_READ			3&&		&& - code for message has been read
#define RELEASE_DATA_MSG		4&&		&& - code for nightaudit release data message
#define LOG_SHOW_DEF_DAYS		7&&		&& - Show last N days from logger

*external reservation server identificator
#define DIRS_SERVER_ID				1
#define CLTZ_SERVER_ID				2
#define WEBRES_SERVER_ID			3
#define HOSC_SERVER_ID				4
#define CSTATION_SERVER_ID			5
#define WEBSERVICE_SERVER_ID		6
#define WEBMEDIA_SERVER_ID			7
#define CITADEL_SERVER_ID			8
#define RHNCHANNELPRO_SERVER_ID		9
#define CITADEL_BOOKING_SERVER_ID	10
#define PARITYRATE_SERVER_ID		11
#define HOTELNETSOLUTIONS_SERVER_ID 12
#define HOTELSPIDER_SERVER_ID		13
#define SITEMINDER_SERVER_ID		14
#define PROFITROOM_SERVER_ID		15
#define AVAILPRO_SERVER_ID			16
#define DIRSV3_SERVER_ID			17
#define SABRE_SERVER_ID				18
#define HOTELPARTNERYM_SERVER_ID	19
#define HRS_IMWEB_SERVER_ID			20

* ini file
#define INI_FILE			_screen.oGlobal.choteldir+"citadel.ini"
* local ini file
#define INI_LOCAL_FILE		"citlocal.ini"

*---- Bind Event ----

#define LETTERS				1
#define WINDOW_LIST_MENU	2

*---- Windows Messages ----

#define WS_VISIBLE			0x10000000
#DEFINE WM_CREATE 			0x0001
#define WM_ACTIVATE			0x0006
#DEFINE WM_SHOWWINDOW		0x0018
#define WM_GETMINMAXINFO	0x0024
#DEFINE WM_SETFOCUS			0x0007
#DEFINE WM_KILLFOCUS		0x0008
#define WM_ENTERMENULOOP	0x0211
#DEFINE WM_DESTROY			0x0002
#DEFINE WM_SETTEXT			0x000C
#DEFINE WM_SIZE				0x0005
#define GWL_WNDPROC			-4

#define WS_MINIMIZE		0x20000000

*--WM_ACTIVATE state values--
#define WA_ACTIVE				1
#define WA_INACTIVE				0

*--Name of record in screens table for toolbar settings--
#define SCREENS_TOOLBAR			"TOOLBARSETTINGS"

*--Debitor / Creditor settings--
#define DEBITOR_PAY_COND_LABEL		"ARPCOND"
#define CREDITOR_PAY_COND_LABEL		"CRPCOND"
#define DEBITOR_REMAINDER_LABEL		"ARREMD"
#define CREDITOR_REMAINDER_LABEL	"CRREMD"

*--resaddr / Guests--
#define RESADDR_DAY_CORRECTION		1
#define RESADDR_LAST_DAY_CORRECTION	1
#define RESADDR_GUEST_NOT_SELECTED	"*"

*--extended MAPI
#Define MAPI_ORIG	0
#Define MAPI_TO		1
#Define MAPI_CC		2
#Define MAPI_BCC	3

#Define IMPORTANCE_LOW			0
#Define IMPORTANCE_NORMAL		1
#Define IMPORTANCE_HIGH			2

* Deposit
#Define DEPOSIT_AUTO_WINDOW		5

* EXE Name
#Define APP_EXE_NAME			"citadel.exe"
#Define APP_EXE_OLD_NAME		"citadel_old.exe"
#Define APP_TRAINING_FOLDER		_screen.oGlobal.choteldir+"training"

* Bill types:
#Define C_BILL_TYPE_UNDEFINED	0 && Before update to 9.08.85
#Define C_BILL_TYPE_GUEST		1
#Define C_BILL_TYPE_COMPANY		2

#DEFINE C_ADDRESS_BILL_NO_VAT_COLOR		RGB(213,255,170)
#DEFINE C_ADDRESS_EXTRESER_COLOR		RGB(255,213,170)
#DEFINE C_COMSERVERS_BLOCK_FILE			"dsrvblock.txt"
#DEFINE C_DESKEXELOGIN_BLOCK_FILE		"ddeskexeblock.txt"
#DEFINE CSRV_SIGNATURE					"52764219-f684-4b95-b3df-c97c7171f0d7"
#DEFINE DS_SIGNATURE					"d0b02830-e8e3-11df-9492-0800200c9a66"

* VFP and static tables used in Commonclasses.prg
#DEFINE C_VFPDATATABLE			'"SHEET   ","HSHEET  ","IFCLOST "'
#DEFINE C_USETABLESVFP			C_VFPDATATABLE+',"LICENSE ","FILES   ","FIELDS  ","TPAUDIT ","TPJOUR  ","TPJRNDAY","TPOPEN  ","TPPAY   ","TPPAYDAY","TPTMPJOU","TPTMPPAY"'
#DEFINE C_STATICDATATABLE		'"ROOM    ","ROOMTYPE"'
#DEFINE C_STATICDATATABLE_ODBC	'"PARAM   ","PARAM2  ","BUILDING","RTYPEDEF","PICKLIST","PAYMETHO","RATECODE","RATEARTI","RATEPROP","ARTICLE ","PRTYPES ","CITCOLOR","ROOMFEAT","ROOMPICT","SEASON  ","TITLE   ","ADRTORES"'

* Error codes
#DEFINE NO_ERROR			0
#DEFINE ERR_COMMIT			-1
#DEFINE ERR_RES_EXISTS		-2

* Table reservation statuses
#DEFINE TR_DEF				0
#DEFINE TR_ASG				1
#DEFINE TR_IN				2
#DEFINE TR_OUT				3
#DEFINE TR_NS				4
#DEFINE TR_CXL				5

* Macnetix
#DEFINE MACNETIX_CAPTION		"Macnetix@on-balance"

*For Ctrl+F5 - colors
#DEFINE APS_LOWERPRICE_COLOR	0x00C000	&& RGB(0,192,0)
#DEFINE APS_EQUALPRICE_COLOR	0x000000	&& RGB(0,0,0)
#DEFINE APS_HIGHIERPRICE_COLOR	0x0000FF	&& RGB(255,0,0)
#DEFINE CTW_LOWERPRICE_COLOR	0x4040C0	&& RGB(192,64,64)
#DEFINE CTW_EQUALPRICE_COLOR	0x808080	&& RGB(128,128,128)
#DEFINE CTW_HIGHIERPRICE_COLOR	0x40C040	&& RGB(64,192,64)
#DEFINE APS_BLOCKED				0
#DEFINE APS_ALLZEROS			1
#DEFINE CTW_PRICES				2