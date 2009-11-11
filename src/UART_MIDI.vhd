--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MY_TYPES.ALL;
use work.MY_CONST.ALL;

entity UART_MIDI is
    Port ( CLK, RAZ : in std_logic;
           BUSY_UART : out std_logic;
           START_UART : in std_logic;
           DATA : in std_logic_vector(7 downto 0);
           TxD : out std_logic);
end UART_MIDI;

architecture UART of UART_MIDI is

signal NBIT  : integer range 0 to NB_BIT;
signal ETAT_UART  : T_ETAT_UART;
signal TIMER : integer range 0 to 799;

begin
----------------------------------------------------------
-- Clock de 31,250 kHz
P_TIMER : process(CLK)
begin
	if RAZ ='1' then
		TIMER <= 0;
	elsif CLK'event and CLK='1' then
		if TIMER = 799 then
			TIMER <= 0;
		else
			TIMER <= TIMER +1;
		end if;
	end if;
end process P_TIMER;
----------------------------------------------------------
-- séquencement de la sérialisation
SEQUENCEUR : process (CLK, RAZ)
begin
	if RAZ ='1' then
		ETAT_UART <= E0;
	elsif CLK'event and CLK = '1' then
		if TIMER = 0 then
			case ETAT_UART is
				when E0 => TxD <= '1';
					     if START_UART = '1' then 
						  		ETAT_UART <= E1;
					     end if;
				when E1 => TxD <= '0';
					        BUSY_UART <= '1';
					        ETAT_UART <= E2;
				when E2 => TxD <= DATA(NBIT);
					        if NBIT = 7 then 
						  			ETAT_UART <= E3;
					        end if;
				when E3 => TxD <= '1';
					        BUSY_UART <='0';
					        ETAT_UART <= E0;
			end case;
		end if;
	end if;
end process SEQUENCEUR;
----------------------------------------------------------
-- Comptage du nombre de bits traités
P_NBIT : process(CLK,RAZ)
begin
	if RAZ = '1' then NBIT <= 0;
	elsif CLK'event and CLK = '1' then
		if TIMER = 0 then
			if ETAT_UART = E0 then 
				NBIT <= 0;
			elsif ETAT_UART = E2 then 
				NBIT <= NBIT + 1;
			end if;
		end if;
	end if;
end process P_NBIT;
----------------------------------------------------------
----------------------------------------------------------
end UART;
