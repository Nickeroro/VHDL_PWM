-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity pwm_tb is
end pwm_tb;
-------------------------------------------------------------------------------

architecture bhe of pwm_tb is

signal s_writep   		: std_logic ;--
signal s_write_data 		: std_logic_vector (31 downto 0); --
signal s_resetn 		: std_logic ; --
signal s_read_p    		: std_logic ; --
signal s_read_data    		: std_logic_vector (31 downto 0);--
signal s_pwm_out      		: std_logic ; --
signal s_avalon_chip_select     : std_logic ; --
signal s_address    		: std_logic_vector (1 downto 0);--
-----------------
constant HALF_PERIOD : time := 10 ns;--
signal s_clk: std_logic :='0';--
signal running  : boolean :=true;--
-----------------

begin  
  
    DUT : entity work.pwm_avalon_interface(syn)
    port map (
    clk                => s_clk,                                 
    resetn             => s_resetn,                                
    avalon_chip_select => s_avalon_chip_select,  --chip_select à 1 au depart                                          
    address            => s_address,            
    writep             => s_writep,                           
    write_data         => s_write_data,          
    readp              => s_read_p,                                
    read_data          => s_read_data,          
    pwm_out            => s_pwm_out  
    );

s_clk                   <= not(s_clk) after HALF_PERIOD when running else '0'; 
s_resetn                <= '0','1' after 10ns;


test:process
begin
	wait until s_resetn = '1';		--Il faut que reset_n soit a 1 pour demarrer
	wait until rising_edge (s_clk);
	s_avalon_chip_select <= '1';		--Il faut que chip_select  ET writep soient a 1
	wait until rising_edge (s_clk);		--pour pouvoir ecrire
	s_writep <= '1';			--
	wait until rising_edge (s_clk);
	s_address <= "00";			--On selectionne l'adresse 00 pour pouvoir ecrire sur clock_divide_reg_selected
	wait until rising_edge (s_clk);
	s_write_data <= x"00000008";		--On ecrit sur clock_divide_reg_selected (Clock divide = 8) 
	wait until rising_edge (s_clk);
	s_address <= "01";			--On selectionne l'adresse 01 pour pouvoir ecrire sur duty_cycle_reg_selected
	wait until rising_edge (s_clk);
	s_write_data <= x"00000002";		--On ecrit sur duty_cycle_reg_selected (Dduty cycle = 2) (2/8 = 25% du temps au niveau bas)
	wait until rising_edge (s_clk);
	s_address <= "10";			--On selectionne l'adresse 10 pour pouvoir ecrire sur enable_reg_selected
	wait until rising_edge (s_clk);
	s_write_data <= x"00000001"; 		--On ecrit sur enable_reg_selected "1" pour pouvoir lancer le pwm
	for i in 0 to 10 loop			--On attend 10 fronts montants
        wait until rising_edge(s_clk);
        end loop;

        wait until rising_edge (s_clk);
	s_address <= "01";			--On selectionne l'adresse 01 pour pouvoir ecrire sur duty_cycle_reg_selected
	wait until rising_edge (s_clk);
	s_write_data <= x"00000004"; 		--On ecrit sur duty_cycle_reg_selected (Dduty cycle = 4) (4/8 = 50% du temps au niveau bas)
        for i in 0 to 10 loop			--On attend 10 fronts montants
        wait until rising_edge(s_clk);
        end loop;

end process;					--On termine le processus
end bhe;					

