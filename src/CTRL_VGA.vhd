--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-LOUTRES
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CTRL_VGA is
	Port(
-- Entrées/sorties du système 
	CLK: in std_logic;
	VSYNC, BLANK, HSYNC: out std_logic;
	X : out integer range 0 to 799;
	Y : out integer range 0 to 524);

end CTRL_VGA;

architecture ARCH_CTRL_VGA of CTRL_VGA is

-- sigaux internes
signal XX: integer range 0 to 799;
signal YY: integer range 0 to 524;

begin
-- signaux asynchrones

BLANK <= '1' when XX > 639 or YY > 479 else '0';
VSYNC <= '0' when YY = 493 or YY = 494 else '1';
HSYNC <= '0' when XX > 658 and XX < 756 else '1';
X <= XX;
Y <= YY;

--------------------------------------------------------------------------------
P_XX: process (CLK)
begin

if (CLK'event and CLK='1') then
	if (XX < 799) then XX <= XX+1;
	else XX <= 0;
	end if;
end if;

end process P_XX;

--------------------------------------------------------------------------------
P_YY: process (CLK)
begin

if (CLK'event and CLK='1') then
	if XX = 0 then
		if (YY < 524) then YY <= YY+1;
		else YY <= 0;
		end if;
	end if;
end if;

end process P_YY;

--------------------------------------------------------------------------------

end ARCH_CTRL_VGA;