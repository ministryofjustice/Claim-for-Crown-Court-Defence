// Core libraries
import $ from 'jquery'
import Rails from '@rails/ujs'
import './plugins/jquery.numbered.elements.js'
import 'jquery.iframe-transport'
import 'chartkick/chart.js'
import 'jquery-accessible-accordion-aria'
import 'jsrender/jsrender'
import 'jquery-highlight'
import 'jquery-throttle-debounce/jquery.ba-throttle-debounce'

// Vendor modules
import './vendor/polyfill.object.keys.js'
import './vendor/bind.js'
import './vendor/moj.js'
import './vendor/cocoon.js'
import './vendor/jquery.remotipart.js'
import './vendor/modules/moj.tabs.js'

// DataTables
import DataTable from 'datatables.net'
import Buttons from 'datatables.net-buttons'
import FixedHeader from 'datatables.net-fixedheader'
import Select from 'datatables.net-select'
import 'jquery-datatables-checkboxes'

// Application modules
import './modules/Modules.OffenceSearchView.js'
import './modules/Plugin.jqDataTable.filter.js'
import './modules/Helpers.API.Establishments.js'
import './modules/Modules.AllocationDataTable.js'
import './modules/Modules.AutocompleteWrapper.js'
import './modules/Modules.OffenceSearchInput.js'
import './modules/Modules.HideErrorOnChange.js'
import './modules/Modules.DataTables.js'
import './modules/Modules.ExpensesDataTable.js'
import './modules/Modules.Debounce.js'
import './modules/case_worker/admin/Modules.ManagementInformation.js'
import './modules/case_worker/Allocation.js'
import './modules/case_worker/claims/DeterminationCalculator.js'
import './modules/external_users/claims/FeeFieldsDisplay.js'
import './modules/external_users/claims/DisbursementsCtrl.js'
import './modules/external_users/claims/FeeTypeCtrl.js'
import './modules/external_users/claims/TransferDetailsCtrl.js'
import './modules/external_users/claims/NewClaim.js'
import './modules/external_users/claims/SideBar.js'
import './modules/external_users/claims/TransferDetailFieldsDisplay.js'
import './modules/external_users/claims/BlockHelpers.js'
import './modules/external_users/claims/CocoonHelper.js'
import './modules/external_users/claims/CaseTypeCtrl.js'
import './modules/external_users/claims/BasicFeeDateCtrl.js'
import './modules/external_users/claims/OffenceCtrl.js'
import './modules/external_users/claims/DuplicateExpenseCtrl.js'
import './modules/external_users/claims/InterimFeeFieldsDisplay.js'
import './modules/external_users/claims/SchemeFilter.js'
import './modules/external_users/claims/fee_calculator/FeeCalculator.GraduatedPrice.js'
import './modules/external_users/claims/fee_calculator/FeeCalculator.UnitPrice.js'
import './modules/external_users/claims/fee_calculator/FeeCalculator.js'
import './modules/external_users/claims/ClaimIntentions.js'
import './modules/Modules.AmountAssessed.js'
import './modules/Modules.OffenceSelectedView.js'
import './modules/show-hide-content.js'
import './modules/Helpers.FormControls.js'
import './modules/Modules.ReAllocationFilterSubmit.js'
import './modules/Helpers.API.Distance.js'
import './modules/Modules.SelectAll.js'
import './modules/Helpers.API.Core.js'
import './modules/Modules.Messaging.js'
import './modules/Helpers.DataTables.js'
import './modules/Helpers.Autocomplete.js'
import './modules/Modules.TableRowClick.js'
import './modules/Modules.AllocationScheme.js'
import './modules/Modules.AddEditAdvocate.js'
import './modules/Modules.MultiFileUpload.js'
import './modules/Modules.TinyPubSub.js'
import './modules/Modules.TruncPolyfill.js'
import './modules/Modules.StringInterpolation.js'
import './modules/Modules.Miscellaneous.js'

// GOV.UK Frontend
import { initAll } from 'govuk-frontend'

// Initialisations
window.jQuery = $
window.$ = $

DataTable(window, $)
Buttons(window, $)
FixedHeader(window, $)
Select(window, $)

initAll()

Rails.start()
