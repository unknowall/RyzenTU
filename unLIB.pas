unit unLIB;

interface

uses Windows, SysUtils;

const
  LIBNAME = 'libryzenadj.dll';

function init_ryzenadj: Pointer; stdcall; external LIBNAME name 'init_ryzenadj';
procedure cleanup_ryzenadj(adj: Pointer); stdcall; external LIBNAME name 'cleanup_ryzenadj';

function init_table(adj: Pointer): Integer; stdcall; external LIBNAME name 'init_table';
function refresh_table(adj: Pointer): Integer; stdcall; external LIBNAME name 'refresh_table';

function get_table_ver(adj: Pointer): Integer; stdcall; external LIBNAME name 'get_table_ver';
function get_table_size(adj: Pointer): Integer; stdcall; external LIBNAME name 'get_table_size';
function get_table_values(adj: Pointer): Pointer; stdcall; external LIBNAME name 'get_table_values';

function get_cpu_family(adj: Pointer): Integer; stdcall; external LIBNAME name 'get_cpu_family';
function get_bios_if_ver(adj: Pointer): Integer; stdcall; external LIBNAME name 'get_bios_if_ver';

function get_core_clk(adj: Pointer;val: Integer): Single; stdcall; external LIBNAME name 'get_core_clk';
function get_core_volt(adj: Pointer;val: Integer): Single; stdcall; external LIBNAME name 'get_core_volt';
function get_core_power(adj: Pointer;val: Integer): Single; stdcall; external LIBNAME name 'get_core_power';
function get_core_temp(adj: Pointer;val: Integer): Single; stdcall; external LIBNAME name 'get_core_temp';

function get_mem_clk(adj: Pointer): Single; stdcall; external LIBNAME name 'get_mem_clk';
function get_fclk(adj: Pointer): Single; stdcall; external LIBNAME name 'get_fclk';

function get_soc_power(adj: Pointer): Single; stdcall; external LIBNAME name 'get_soc_power';
function get_soc_volt(adj: Pointer): Single; stdcall; external LIBNAME name 'get_soc_volt';

function get_socket_power(adj: Pointer): Single; stdcall; external LIBNAME name 'get_socket_power';

function get_gfx_clk(adj: Pointer): Single; stdcall; external LIBNAME name 'get_gfx_clk';
function get_gfx_temp(adj: Pointer): Single; stdcall; external LIBNAME name 'get_gfx_temp';
function get_gfx_volt(adj: Pointer): Single; stdcall; external LIBNAME name 'get_gfx_volt';

function get_stapm_limit(adj: Pointer): Single; stdcall; external LIBNAME name 'get_stapm_limit';
function get_stapm_value(adj: Pointer): Single; stdcall; external LIBNAME name 'get_stapm_value';
function get_fast_limit(adj: Pointer): Single; stdcall; external LIBNAME name 'get_fast_limit';
function get_slow_limit(adj: Pointer): Single; stdcall; external LIBNAME name 'get_slow_limit';
function get_apu_slow_limit(adj: Pointer): Single; stdcall; external LIBNAME name 'get_apu_slow_limit';
function get_vrm_current(adj: Pointer): Single; stdcall; external LIBNAME name 'get_vrm_current';
function get_vrmsoc_current(adj: Pointer): Single; stdcall; external LIBNAME name 'get_vrmsoc_current';
function get_vrmmax_current(adj: Pointer): Single; stdcall; external LIBNAME name 'get_vrmmax_current';
function get_vrmsocmax_current(adj: Pointer): Single; stdcall; external LIBNAME name 'get_vrmsocmax_current';
function get_stapm_time(adj: Pointer): Single; stdcall; external LIBNAME name 'get_stapm_time';
function get_slow_time(adj: Pointer): Single; stdcall; external LIBNAME name 'get_slow_time';

function get_tctl_temp(adj: Pointer): Single; stdcall; external LIBNAME name 'get_tctl_temp';
function set_skin_temp_power_limit(adj: Pointer): Single; stdcall; external LIBNAME name 'set_skin_temp_power_limit';

function set_power_saving(adj: Pointer): Integer; stdcall; external LIBNAME name 'set_power_saving';
function set_max_performance(adj: Pointer): Integer; stdcall; external LIBNAME name 'set_max_performance';

function set_tctl_temp(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_tctl_temp';
function set_apu_skin_temp_limit(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_apu_skin_temp_limit';
function set_dgpu_skin_temp_limit(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_dgpu_skin_temp_limit';

function set_stapm_limit(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_stapm_limit';
function set_fast_limit(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_fast_limit';
function set_slow_limit(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_slow_limit';
function set_slow_time(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_slow_time';
function set_stapm_time(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_stapm_time';

function set_vrm_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrm_current';
function set_vrmsoc_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrmsoc_current';
function set_vrmgfx_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrmgfx_current';
function set_vrmmax_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrmmax_current';
function set_vrmsocmax_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrmsocmax_current';
function set_vrmgfxmax_current(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_vrmgfxmax_current';

function set_max_gfxclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_max_gfxclk_freq';
function set_max_fclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_max_fclk_freq';
function set_min_gfxclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_min_gfxclk_freq';
function set_min_fclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_min_fclk_freq';
function set_max_socclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_max_socclk_freq';
function set_min_socclk_freq(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_min_socclk_freq';

function set_enable_oc(adj: Pointer): Integer; stdcall; external LIBNAME name 'set_enable_oc';
function set_disable_oc(adj: Pointer): Integer; stdcall; external LIBNAME name 'set_disable_oc';

function set_oc_clk(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_oc_clk';
function set_oc_volt(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_oc_volt';

function set_coall(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_coall';
function set_coper(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_coper';
function set_cogfx(adj: Pointer;val: Integer): Integer; stdcall; external LIBNAME name 'set_cogfx';

implementation

end.
