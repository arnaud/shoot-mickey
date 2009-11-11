--------------------------------------------------------------------------------
-- Mini-projet VHDL : SHOOT-MICKEY
-- LEYMET Arnaud
-- NONN Vincent
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SOUND is
    Port ( CLK, RAZ : in std_logic;
	        SS : in integer range 0 to 7;
           START : in std_logic;
           STOP : in std_logic;
           TxD : out std_logic
	     );
end SOUND;

architecture S_MIDI of SOUND is



--------------------------------------------------------------------------------
-- Composant CONTROL_SOUND
component CONTROL_SOUND
	Port(
		-- Entrées/sorties du système
		CLK, RAZ: in std_logic;
		START: in std_logic;
		STOP: in std_logic;
		NOTES : out std_logic_vector (6 downto 0);
		ON_OFF : out std_logic;
		START_M : out std_logic;
		BUSY_M : in std_logic;
	   STATUS : out std_logic_vector(7 downto 0)
		);
end component;


--------------------------------------------------------------------------------
-- Composant GENERATEUR_MIDI
component GENERATEUR_MIDI
	Port(
		-- Entrées/sorties du système
		CLK, RAZ: in std_logic;
		NOTES : in std_logic_vector (6 downto 0);
		ON_OFF : in std_logic;
		START_M : in std_logic;
		BUSY_M : out std_logic;
		BUSY_UART : in std_logic;
		START_UART : out std_logic;
		DATA : out std_logic_vector(7 downto 0);
	   STATUS : in std_logic_vector(7 downto 0)
		);
end component;


--------------------------------------------------------------------------------
-- Composant UART_MIDI
component UART_MIDI 
	Port(
		-- Entrées/sorties du système
		CLK, RAZ: in std_logic;
		BUSY_UART : out std_logic;
		START_UART : in std_logic;
		DATA : in std_logic_vector(7 downto 0);
		TxD : out std_logic
		);
end component;


signal NOTES : std_logic_vector (6 downto 0);
signal ON_OFF : std_logic;
signal START_M : std_logic;
signal BUSY_M : std_logic;
signal BUSY_UART : std_logic;
signal START_UART : std_logic;
signal STATUS : std_logic_vector(7 downto 0);
signal DATA : std_logic_vector(7 downto 0);

--------------------------------------------------------------------------------

begin

--------------------------------------------------------------------------------
U10 : CONTROL_SOUND
	Port map(
		CLK => CLK,
		RAZ => RAZ,
		START => START,
		STOP => STOP,
		NOTES => NOTES,
		ON_OFF => ON_OFF,
		START_M => START_M,
		BUSY_M => BUSY_M,
		STATUS => STATUS
		);	

--------------------------------------------------------------------------------
U11 : GENERATEUR_MIDI
	Port map(
		CLK => CLK,
		RAZ => RAZ,
		START_M => START_M,
		BUSY_M => BUSY_M,
		NOTES => NOTES,
		ON_OFF => ON_OFF,
		START_UART => START_UART,
		BUSY_UART => BUSY_UART,
		DATA => DATA,
		STATUS => STATUS
		);	

--------------------------------------------------------------------------------
U12 : UART_MIDI
	Port map(
		CLK => CLK,
		RAZ => RAZ,
		START_UART => START_UART,
		BUSY_UART => BUSY_UART,
		DATA => DATA,
		TxD => TxD
		);	

end S_MIDI;
