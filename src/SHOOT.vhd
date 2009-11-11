--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.MY_CONST.ALL;
use work.MY_TYPES.ALL;

entity SHOOT is
	Port(
-- Entrées/sorties du système 
	NEW_GAME: in std_logic;
	PAUSE: in std_logic;
	RAZ,QUARTZ: in std_logic;
	VSYNC, HSYNC: out std_logic;
	RVB: out std_logic_vector(0 to 2);
	MOUSE_DATA: inout std_logic;
	MOUSE_CLK: in std_logic ;
	TxD: out std_logic
	);

-- Assignation des signaux aux broches
	attribute loc: string;
	attribute loc of RAZ: signal is "L14";
	attribute loc of NEW_GAME: signal is "L13";
	attribute loc of PAUSE: signal is "M14";
	attribute loc of QUARTZ: signal is "T9";
	attribute loc of VSYNC: signal is "T10";
	attribute loc of HSYNC: signal is "R9";
	attribute loc of RVB: signal is "R12,T12,R11";
	attribute loc of MOUSE_DATA: signal is "M15";
	attribute loc of MOUSE_CLK: signal is "M16";
	attribute loc of TxD: signal is "R13";

end SHOOT;

architecture Arch_SHOOT of SHOOT is

-- sigaux internes
signal CLK : std_logic;
signal EN_PAUSE: std_logic;	 
signal EN_INTRO: std_logic;
signal XV, XL : integer range 0 to SCR_WIDTH_MAX;
signal BG, BD : std_logic;
signal YV, YL : integer range 0 to SCR_HEIGHT_MAX;
signal IMPACTS_X : T_IMPACTS_X;
signal IMPACTS_Y : T_IMPACTS_Y;
signal TPS_CLIC : integer range 0 to N_TIMER_MAX;
signal SCORE : integer range 0 to N_SCORE_MAX;
signal TIRS : integer range 0 to N_TIRS_MAX;
signal SS : integer range 0 to 7;
signal START, STOP : std_logic;
signal PREDIV : integer range 0 to 799;
signal PREDIV2 : integer range 0 to 7;

--------------------------------------------------------------------------------
-- Composant CORE
component CORE 
	Port(
		-- Entrées/sorties du système 
		CLK, RAZ: in std_logic;
		NEW_GAME: in std_logic;
		PAUSE: in std_logic;
		EN_PAUSE: out std_logic;
		EN_INTRO: out std_logic;
		XV : in integer range 0 to SCR_WIDTH_MAX;
		YV : in integer range 0 to SCR_HEIGHT_MAX;
		BG, BD : in std_logic;
		XL : out integer range 0 to SCR_WIDTH_MAX;
		YL : out integer range 0 to SCR_HEIGHT_MAX;
		IMPACTS_X : out T_IMPACTS_X;
		IMPACTS_Y : out T_IMPACTS_Y;
		TPS_CLIC : out integer range 0 to N_TIMER_MAX;
		SCORE : out integer range 0 to N_SCORE_MAX;
		TIRS : out integer range 0 to N_TIRS_MAX;
		SS : out integer range 0 to 7;
		START : out std_logic;
      STOP : out std_logic
	);
end component;
--------------------------------------------------------------------------------
-- Composant DISPLAY
component DISPLAY is
	Port(
		-- Entrées/sorties du système
		CLK: in std_logic;
		EN_PAUSE: in std_logic;
		EN_INTRO: in std_logic;
		XV, XL: in integer range 0 to SCR_WIDTH_MAX;
		YV, YL: in integer range 0 to SCR_HEIGHT_MAX;
		IMPACTS_X : in T_IMPACTS_X;
		IMPACTS_Y : in T_IMPACTS_Y;
		TPS_CLIC : in integer range 0 to N_TIMER_MAX;
		SCORE : in integer range 0 to N_SCORE_MAX;
		TIRS: in integer range 0 to N_TIRS_MAX;
		VSYNC, HSYNC: out std_logic;
		RVB: out std_logic_vector(0 to 2)
	);
end component;

--------------------------------------------------------------------------------
-- Composant SOUND
component SOUND 
	Port(
		-- Entrées/sorties du système
		CLK, RAZ: in std_logic;
		START: in std_logic;
		STOP : in std_logic;
		SS : in integer range 0 to 7;
		TxD : out std_logic
	);
end component;

--------------------------------------------------------------------------------
-- Composant SOURIS
component SOURIS 
	Port(
		-- Entrées/sorties du système
		clock, raz : in std_logic;
		MOUSE_DATA : inout std_logic;
		MOUSE_CLK : in std_logic;
		XP : out integer range 0 to SCR_WIDTH_MAX;
		YP : out integer range 0 to SCR_HEIGHT_MAX;
		BG : out std_logic;
		BD : out std_logic
	);
end component;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------
-- Déclaration des components
COMP_CORE : CORE 
	Port map(
		CLK => CLK,
		RAZ => RAZ,
		NEW_GAME => NEW_GAME,
		PAUSE => PAUSE,
		EN_PAUSE => EN_PAUSE,
		EN_INTRO => EN_INTRO,
		XV => XV,
		YV => YV,
		BG => BG,
		BD => BD,
		XL => XL,
		YL => YL,
		IMPACTS_X => IMPACTS_X,
		IMPACTS_Y => IMPACTS_Y,
		TPS_CLIC => TPS_CLIC,
		SCORE => SCORE,
		TIRS => TIRS,
		SS => SS,
      START => START,
      STOP => STOP
	);
--------------------------------------------------------------------------------
COMP_DISPLAY : DISPLAY 
	Port map(
		CLK => CLK,
		EN_PAUSE => EN_PAUSE,
		EN_INTRO => EN_INTRO,
		XV => XV,
		XL => XL,
		YV => YV,
		YL => YL,
		IMPACTS_X => IMPACTS_X,
		IMPACTS_Y => IMPACTS_Y,
		TPS_CLIC => TPS_CLIC,
		SCORE => SCORE,
		TIRS => TIRS,
		VSYNC => VSYNC,
		HSYNC => HSYNC,
		RVB => RVB
	);
--------------------------------------------------------------------------------
COMP_SOURIS : SOURIS 
	Port map(
		clock => CLK,
		raz => RAZ,
		MOUSE_DATA => MOUSE_DATA,
		MOUSE_CLK => MOUSE_CLK,
		XP => XV,
		YP => YV,
		BG => BG,
		BD => BD
	);	  
--------------------------------------------------------------------------------
COMP_SOUND : SOUND
	Port map(
		CLK => CLK,
		RAZ => RAZ,
		START => START,
		STOP => STOP,
		SS => SS,
		TxD => TxD
	);	
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Clock de 25 MHz
P_CLK: process(QUARTZ)
begin
	if (QUARTZ'event and QUARTZ='1') then
		CLK <= not CLK;
	end if;
end process P_CLK;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
end Arch_SHOOT;
