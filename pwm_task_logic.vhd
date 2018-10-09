library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-----------------------------------------------------------------------------
-- File: pwm_task_logic.vhd                                                  --
-- Description: This module contains the core of the pwm functionality.    --
--    The clock_divide and duty_cycle inputs are used in conjunction with  --
--    a counter to determine how long the pwm output stays high and low.   --
--    The output is 1 bit.                                                 --
-----------------------------------------------------------------------------

entity pwm_task_logic is
  
  port (
    clk          : in  std_logic;
    pwm_enable   : in  std_logic;
    resetn       : in  std_logic;
    clock_divide : in  std_logic_vector (31 downto 0);
    duty_cycle   : in  std_logic_vector (31 downto 0);
    pwm_out      : out std_logic);

end pwm_task_logic;

architecture syn of pwm_task_logic is

  signal counter : std_logic_vector(31 downto 0);
  signal pwm : std_logic;  

begin  -- syn
	
  -- purpose: PWM Counter Process
  -- type   : sequential
  -- inputs : clk, resetn, pwm_enable, clock_divide
  -- outputs: counter
  process (clk, resetn)
  begin  -- process
    if resetn = '0' then                -- asynchronous reset (active low)
      counter <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (pwm_enable = '1') then
	 if (counter >= clock_divide) then
           counter <= (others => '0'); 
	 else
           counter <= counter + 1;
         end if;
      else
        counter <= counter;
      end if;  
    end if;
  end process;

  -- purpose: PWM Comparitor
  -- type   : sequential
  -- inputs : clk, resetn, counter, duty_cycle
  -- outputs: pwm
  process (clk, resetn)
  begin  -- process
    if resetn = '0' then                -- asynchronous reset (active low)
      pwm <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if(pwm_enable = '1') then
      	if (counter >= duty_cycle) then
		  pwm <= '1';
        else
          if (counter = 0) then
            pwm <= '0';
		  else
		    pwm <= pwm;
	  	  end if;
		end if;
      else
		pwm <= '0';
      end if;
    end if;
  end process;
 
  pwm_out <= pwm;
	
end syn;

