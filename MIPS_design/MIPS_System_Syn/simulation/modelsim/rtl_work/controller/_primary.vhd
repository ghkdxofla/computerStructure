library verilog;
use verilog.vl_types.all;
entity controller is
    port(
        op              : in     vl_logic_vector(5 downto 0);
        signext         : out    vl_logic;
        shiftl16        : out    vl_logic;
        memtoreg        : out    vl_logic_vector(1 downto 0);
        memwrite        : out    vl_logic;
        memread         : out    vl_logic;
        alusrc          : out    vl_logic;
        regdst          : out    vl_logic_vector(1 downto 0);
        regwrite        : out    vl_logic;
        jump            : out    vl_logic_vector(1 downto 0);
        aluop           : out    vl_logic_vector(1 downto 0);
        branch          : out    vl_logic_vector(1 downto 0)
    );
end controller;