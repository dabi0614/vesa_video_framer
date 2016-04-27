-- Author: David Thach
-- Date: 2016.04.28

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity image_gen is
    port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           en : in  STD_LOGIC;
           DE : in  STD_LOGIC;
           RGB : out  STD_LOGIC_VECTOR (23 downto 0));
end image_gen;

architecture behavioral of image_gen is

constant shade_level_max : integer := 256;
signal shade_level : integer := 0;

begin
	update_shade:
	process (clk, rst, en, DE)
	begin
		if (rst = '1') then
			shade_level <= 0; -- Reset 0
		elsif (en = '1') then
			if (rising_edge (clk)) then
				if (DE = '1') then
					RGB <= conv_std_logic_vector(shade_level, 8)
								& conv_std_logic_vector(shade_level, 8)
								& conv_std_logic_vector(shade_level, 8);
					shade_level <= (shade_level + 1) mod shade_level_max;
				else
					RGB <= (others => '0');
					shade_level <= 0;
				end if;
			end if;
		end if;
	end process update_shade;

end behavioral;

