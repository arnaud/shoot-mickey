----------------------------------------------------------------
-- Generateur  des chiffres del'affichage du score
-- Les chiffres sont matricés  en pavés de 8x8 points
----------------------------------------------------------------
-- D.genet Avril 2004
----------------------------------------------------------------
-- Cette description du contenu de la table DATA est telle
-- que le synthétiseur SYNPLIFY l'implémentera automatiquement
-- à l'aide ressources RAM du FPGA si celui-ci en contient.
----------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
----------------------------------------------------------------
entity GEN_CHIFFRE is

port(	
	CHIFFRE : in integer range 0 to 9;	-- chiffre à afficher
  	YC : in integer range 0 to 7;		-- abcisse du point
	XC : in integer range 0 to 7;		-- ordonnée du point
	VALID : in std_logic;			-- validation
	VC : out std_logic);			-- valeur du point
end  GEN_CHIFFRE;	

architecture ARCH_GEN_CHIFFRE of GEN_CHIFFRE is

signal ADDR : std_logic_vector (6 downto 0);
signal DATA : std_logic_vector (0 to 7);

-- Directive de synthèse pour SYNPLIFY
attribute syn_romstyle : string;
attribute syn_romstyle of DATA : signal is "select_rom";
----------------------------------------------------------------
begin 

ADDR <= conv_std_logic_vector(CHIFFRE,4)& conv_std_logic_vector( YC,3);

P_ROM : process (ADDR)
begin

-- ROM génératrice de caractères
	case conv_integer(ADDR) is
		when 00 => DATA <= "00111100";
		when 01 => DATA <= "01100110"; --   **  **    %
		when 02 => DATA <= "01101110"; --   ** ***    %
		when 03 => DATA <= "01110110"; --   *** **    %
		when 04 => DATA <= "01100110"; --   **  **    %
		when 05 => DATA <= "01100110"; --   **  **    %
		when 06 => DATA <= "00111100"; --    ****     %
		when 07 => DATA <= "00000000"; --             %
	
		when 08 => DATA <= "00011000"; --     **      %
		when 09 => DATA <= "00011000"; --     **    . % 
		when 10 => DATA <= "00111000"; --    ***      %
		when 11 => DATA <= "00011000"; --     **      %
		when 12 => DATA <= "00011000"; --     **      %
		when 13 => DATA <= "00011000"; --     **      %
		when 14 => DATA <= "01111110"; --   ******    %
		when 15 => DATA <= "00000000"; --             %
		
		when 16 => DATA <= "00111100"; --    ****     %
		when 17 => DATA <= "01100110"; --   **  **    %
		when 18 => DATA <= "00000110"; --       **    %
		when 19 => DATA <= "00001100"; --      **     %
		when 20 => DATA <= "00110000"; --    **       %
		when 21 => DATA <= "01100000"; --   **        %
		when 22 => DATA <= "01111110"; --   ******    %
		when 23 => DATA <= "00000000"; --             %
		
		when 24 => DATA <= "00111100"; --    ****     %
		when 25 => DATA <= "01100110"; --   **  **    %
		when 26 => DATA <= "00000110"; --       **    %
		when 27 => DATA <= "00011100"; --     ***     %
		when 28 => DATA <= "00000110"; --       **    %
		when 29 => DATA <= "01100110"; --   **  **    %
		when 30 => DATA <= "00111100"; --    ****     %
		when 31 => DATA <= "00000000"; --             %
		
		when 32 => DATA <= "00000110"; --       **    %
		when 33 => DATA <= "00001110"; --      ***    %
		when 34 => DATA <= "00011110"; --     ****    %
		when 35 => DATA <= "01100110"; --   **  **    %
		when 36 => DATA <= "01111111"; --   *******   %
		when 37 => DATA <= "00000110"; --       **    %
		when 38 => DATA <= "00000110"; --       **    %
		when 39 => DATA <= "00000000"; --             %

		when 40 => DATA <= "01111110"; --   ******    %
		when 41 => DATA <= "01100000"; --   **        %
		when 42 => DATA <= "01111100"; --   *****     %
		when 43 => DATA <= "00000110"; --       **    %
		when 44 => DATA <= "00000110"; --       **    %
		when 45 => DATA <= "01100110"; --   **  **    %
		when 46 => DATA <= "00111100"; --    ****     %
		when 47 => DATA <= "00000000"; --             %
		
		when 48 => DATA <= "00111100"; --    ****     %
		when 49 => DATA <= "01100110"; --   **  **    %
		when 50 => DATA <= "01100000"; --   **        %
		when 51 => DATA <= "01111100"; --   *****     %
		when 52 => DATA <= "01100110"; --   **  **    %
		when 53 => DATA <= "01100110"; --   **  **    %
		when 54 => DATA <= "00111100"; --    ****     %
		when 55 => DATA <= "00000000"; --             %

		when 56 => DATA <= "01111110"; --   ******    %
		when 57 => DATA <= "01100110"; --   **  **    %
		when 58 => DATA <= "00001100"; --      **     %
		when 59 => DATA <= "00011000"; --     **      %
		when 60 => DATA <= "00011000"; --     **      %
		when 61 => DATA <= "00011000"; --     **      %
		when 62 => DATA <= "00011000"; --     **      %
		when 63 => DATA <= "00000000"; --             %
		
		when 64 => DATA <= "00111100"; --    ****     %
		when 65 => DATA <= "01100110"; --   **  **    %
		when 66 => DATA <= "01100110"; --   **  **    %
		when 67 => DATA <= "00111100"; --    ****     %
		when 68 => DATA <= "01100110"; --   **  **    %
		when 69 => DATA <= "01100110"; --   **  **    %
		when 70 => DATA <= "00111100"; --    ****     %
		when 71 => DATA <= "00000000"; --             %
	
		when 72 => DATA <= "00111100"; --    ****     %
		when 73 => DATA <= "01100110"; --   **  **    %
		when 74 => DATA <= "01100110"; --   **  **    %
		when 75 => DATA <= "00111110"; --    *****    %
		when 76 => DATA <= "00000110"; --       **    %
		when 77 => DATA <= "01100110"; --   **  **    %
		when 78 => DATA <= "00111100"; --    ****     %
		when 79 => DATA <= "00000000"; --             %
		when others => data <= "00000000";

	end case;
end process P_ROM;

P_VC : process (VALID,XC,DATA)
begin
	if VALID  = '1' then
		VC <= DATA(XC);
	else VC <= '0';
	end if;
end process P_VC;
	
end ARCH_GEN_CHIFFRE;
