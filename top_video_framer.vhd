-- Author: David Thach
-- Date: 2016.04.28

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_video_framer is
    Port ( clk_in : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           res_sel : in  STD_LOGIC;
           clk_out : out  STD_LOGIC;
           DE : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (23 downto 0));
end top_video_framer;

architecture behavioral of top_video_framer is

component video_framer 
	    port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           res_sel : in  STD_LOGIC;
           DE : out  STD_LOGIC;
           HS : out  STD_LOGIC;
           VS : out  STD_LOGIC);
end component video_framer;

component image_gen is
    port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           DE : in  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (23 downto 0));
end component image_gen;

signal DE_int : STD_LOGIC;

begin

VID_FRAMER : video_framer
	port map (clk => clk_in,
           rst => rst,
           en => en,
           res_sel => res_sel,
           DE => DE_int,
           HS => HS,
           VS => VS);

IMG_GEN : image_gen
	port map (clk => clk_in,
           rst => rst,
           en => en,
           DE => DE_int,
           RGB => RGB);

clk_out <= clk_in;
DE <= DE_int;

end behavioral;

