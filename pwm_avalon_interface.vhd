-----------------------------------------------------------------------------
-- File: pwm_avalon_interface.vhd                                           --
-- Description: Top level module.  Instantiates pwm_task_logic and         --
--    pwm_register_file modules and adds Avalon slave interface.           --
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity  pwm_avalon_interface is
  
  port (
    clk                : in  std_logic;                                 -- System clock - tied to all blocks
    resetn             : in  std_logic;                                 -- System reset - tied to all blocks
    avalon_chip_select : in  std_logic;                                 -- Avalon Chip select            
    address            : in  std_logic_vector (1 downto 0);             -- Avalon Address bus
    writep              : in  std_logic;                                 -- Avalon Write signal
    write_data         : in  std_logic_vector (31 downto 0);            -- Avalon Write data bus
    readp               : in  std_logic;                                 -- Avalon Read signal
    read_data          : out std_logic_vector (31 downto 0);            -- Avalon Read data bus
    pwm_out            : out std_logic);                                -- PWM output signal

end  pwm_avalon_interface;

architecture syn of pwm_avalon_interface is

  -- Avalon_Slave_PWM Interal Nodes
  signal pwm_clock_divide : std_logic_vector(31 downto 0);  -- Clock divide wire from register file to pwm task logic
  signal pwm_duty_cycle : std_logic_vector (31 downto 0);   -- Duty cycle value from register file to pwm task logic
  signal pwm_enable : std_logic;                            -- PWM enable signal from register file to pwm task logic

component pwm_register_file
  
  port (
    -- Avalon Signals
    clk              : in  std_logic;                           -- System Clock
    resetn           : in  std_logic;                           -- System Reset
    chip_select      : in  std_logic;                           -- Avalon Chip select signal
    address          : in  std_logic_vector(1 downto 0);        -- Avalon Address bus
    writep           : in  std_logic;                           -- Avalon Write signal
    write_data       : in  std_logic_vector(31 downto 0);       -- Avalon Write data bus
    readp            : in  std_logic;                           -- Avalon read signal
    read_data        : out std_logic_vector(31 downto 0);       -- Avalon read data bus
    -- PWM Output Signals
    pwm_clock_divide : out std_logic_vector(31 downto 0);       -- PWM clock divide drive signals
    pwm_duty_cycle   : out std_logic_vector(31 downto 0);       -- PWM duty cycle drive signals
    pwm_enable       : out std_logic );                         -- PWM enable drive signals

end component;

component pwm_task_logic
  
  port (
    clk          : in  std_logic;
    pwm_enable   : in  std_logic;
    resetn       : in  std_logic;
    clock_divide : in  std_logic_vector (31 downto 0);
    duty_cycle   : in  std_logic_vector (31 downto 0);
    pwm_out      : out std_logic);

end component;

begin  -- syn
	
  -- PWM Instance
  task_logic : pwm_task_logic port map (
    clk          => clk,
    pwm_enable   => pwm_enable,
    resetn       => resetn,
    clock_divide => pwm_clock_divide,
    duty_cycle   => pwm_duty_cycle,
    pwm_out      => pwm_out);

  -- Register File instance
  register_file : pwm_register_file port map (
    clk              => clk,
    resetn           => resetn,
    chip_select      => avalon_chip_select,
    address          => address,
    writep           => writep,
    write_data       => write_data,
    readp            => readp,
    read_data        => read_data,
    pwm_clock_divide => pwm_clock_divide,
    pwm_duty_cycle   => pwm_duty_cycle,
    pwm_enable       => pwm_enable);

end syn;







