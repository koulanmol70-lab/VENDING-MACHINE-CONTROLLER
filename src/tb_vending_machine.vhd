library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine is
    Port ( 
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;
        coin           : in  STD_LOGIC_VECTOR(1 downto 0);
        select_product : in  STD_LOGIC;
        dispense       : out STD_LOGIC;
        change         : out STD_LOGIC 
    );
end vending_machine;

architecture Behavioral of vending_machine is

    -- Completely clean state names to avoid any possible conflict
    type state_type is (ST_IDLE, ST_COIN_1, ST_COIN_2, ST_DISPENSE, ST_CHANGE);
    signal current_state : state_type;
    signal next_state    : state_type;

begin

    -- Process 1: Clocked State Register
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= ST_IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Process 2: Combinational Next State Logic
    process(current_state, coin, select_product)
    begin
        -- Safe default state hold
        next_state <= current_state;
        
        case current_state is
            when ST_IDLE =>
                if coin = "01" then 
                    next_state <= ST_COIN_1;
                elsif coin = "10" then
                    next_state <= ST_COIN_2;
                else 
                    next_state <= ST_IDLE;
                end if;
                
            when ST_COIN_1 =>
                if coin = "01" then 
                    next_state <= ST_COIN_2;
                elsif coin = "10" then
                    next_state <= ST_DISPENSE;
                else 
                    next_state <= ST_COIN_1;
                end if;
                
            when ST_COIN_2 =>
                if select_product = '1' then 
                    next_state <= ST_DISPENSE;
                else 
                    next_state <= ST_COIN_2;
                end if;
                
            when ST_DISPENSE =>
                next_state <= ST_CHANGE;
                
            when ST_CHANGE =>
                next_state <= ST_IDLE;
                
            when others =>
                next_state <= ST_IDLE;
        end case;
    end process;

    -- Process 3: Concurrent Safe Output Assignments
    dispense <= '1' when (current_state = ST_DISPENSE) else '0';
    change   <= '1' when (current_state = ST_CHANGE) else '0';

end Behavioral;
