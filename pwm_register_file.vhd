library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
-- File: pwm_register_file.vhd                                                  --
-- Description: Register interface for PWM.  Contains logic for reading      --
--    and writing to PWM registers.                                          --
-------------------------------------------------------------------------------

entity pwm_register_file is
  
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

end pwm_register_file;

architecture syn of pwm_register_file is

  -- Signal Declarations	
  signal clock_divide_register : std_logic_vector (31 downto 0);	-- Clock divider register
  signal duty_cycle_register : std_logic_vector (31 downto 0);  	-- Duty Cycle Register
  signal enable_register : std_logic;	 	                        -- Enable Bit	

  --Nodes used for address decoding
  signal clock_divide_reg_selected, duty_cycle_reg_selected, enable_reg_selected : std_logic;
  -- Nodes for determining if a valid write occurred to a specific address
  signal write_to_clock_divide, write_to_duty_cycle, write_to_enable : std_logic;
  -- Nodes for determining if a valid read occurred to a specific address
  signal read_to_clock_divide, read_to_duty_cycle, read_to_enable : std_logic;
  -- Nodes used to determine if a valid access has occurred
  signal valid_write, valid_read : std_logic;
  signal enable_reg_0 : std_logic_vector (31 downto 0);
  signal zero : std_logic_vector (30 downto 0);

begin  -- syn

  -- address decode
  clock_divide_reg_selected <= not(address(1)) and not(address(0));  -- address 00
  duty_cycle_reg_selected   <= not(address(1)) and address(0);       -- address 01
  enable_reg_selected       <=  address(1) and  not(address(0));     -- address 10

  -- determine if a vaild transaction was initiated 
  valid_write <= chip_select and writep;		
  valid_read  <= chip_select and readp;

  -- determine if a write occurred to a specific address
  write_to_clock_divide <= valid_write and clock_divide_reg_selected;
  write_to_duty_cycle   <= valid_write and duty_cycle_reg_selected;
  write_to_enable       <= valid_write and enable_reg_selected;

  -- determine if a read occurred to a specific address
  read_to_clock_divide <= valid_read and clock_divide_reg_selected;
  read_to_duty_cycle   <= valid_read and duty_cycle_reg_selected;
  read_to_enable       <= valid_read and enable_reg_selected;

  -- purpose: Write to clock_divide Register
  -- type   : sequential
  -- inputs : clk, resetn, write_data
  -- outputs: clock_divide_register
  process (clk, resetn)
  begin  -- process
    if resetn = '0' then                -- asynchronous reset (active low)
      clock_divide_register <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (write_to_clock_divide = '1') then
        clock_divide_register <= write_data;
      else
        clock_divide_register <= clock_divide_register;
      end if;
    end if;
  end process;

  -- purpose: Write to duty_cycle Register
  -- type   : sequential
  -- inputs : clk, resetn, write_data
  -- outputs: duty_cycle_register
  process (clk, resetn)
  begin  -- process
    if resetn = '0' then                -- asynchronous reset (active low)
      duty_cycle_register <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (write_to_duty_cycle = '1') then
        duty_cycle_register <= write_data;
      else
        duty_cycle_register <= duty_cycle_register;
      end if;
    end if;
  end process;

  -- purpose: Write to enable register
  -- type   : sequential
  -- inputs : clk, resetn, write_data(0)
  -- outputs: enable_register;
  process (clk, resetn)
  begin  -- process
    if resetn = '0' then                -- asynchronous reset (active low)
      enable_register <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if write_to_enable = '1' then
        enable_register <= write_data(0);
      else
        enable_register <= enable_register;
      end if;
    end if;
  end process;

  zero <= (others => '0');
  enable_reg_0 <= zero & enable_register;

  -- Read Data Bus Mux
  read_data <=  clock_divide_register when (read_to_clock_divide = '1') else
                duty_cycle_register when (read_to_duty_cycle = '1') else
                enable_reg_0 when (read_to_enable = '1') else
                (others => '0');

  -- assign register values to register file outputs to the PWM
  pwm_clock_divide <= clock_divide_register;
  pwm_duty_cycle <= duty_cycle_register;
  pwm_enable <= enable_register;

end syn;
