class clk_uvc_drv extends uvm_driver;
    `uvm_component_utils(clk_uvc_drv)

    virtual clk_uvc_if vif;

    clk_uvc_cfg        cfg;
    local bit          clk_enable = 0;

    `uvm_component_new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if((cfg == null) && !uvm_config_db#(clk_uvc_cfg)::get(this, "", "cfg", cfg)) begin
            `uvm_fatal(`gfn, "cfg is neither passed in nor configured.")
        end

        if((vif == null) && !uvm_config_db#(virtual clk_uvc_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(`gfn, "vif is neither passed in nor configured.")
        end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            int unsigned init_phase;
            int unsigned clk_period;

            vif.clk <= 1'b0;
            wait(clk_enable == 1'b1);

            case(cfg.freq_unit)
                "GHz": clk_period = 1000 / cfg.freq;
                "MHz": clk_period = 1000000 / cfg.freq;
                default: `uvm_error(`gfn, $sformatf("Unsupported freq timing unit %0s", cfg.freq_unit))
            endcase

            std::randomize(init_phase) with {
                init_phase <= cfg.phase_max;
                init_phase >= cfg.phase_min;
            };

            init_phase = init_phase % clk_period;

            // Wait for init phase
            #(init_phase * 1ps);

            while(clk_enable == 1'b1) begin
                drv_clk_cycle(clk_period);
            end
        end
    endtask : run_phase

    task drv_clk_cycle(int unsigned clk_period);
        int unsigned adj_clk_period;
        int unsigned adj_duty_cycle;
        int unsigned period_hi;
        int unsigned period_lo;

        std:randomize(adj_clk_period, adj_duty_cycle) with {
            adj_clk_period >= (clk_period + cfg.pjit_min);
            adj_clk_period <= (clk_period + cfg.pjit_max);
            adj_duty_cycle >= cfg.duty_min;
            adj_duty_cycle >= cfg.duty_max;
        };

        period_hi = adj_clk_period * adj_duty_cycle / 100;
        period_lo = adi_clk_period - period_hi;

        vif.clk <= 1'b1;
        #(period_hi * 1ps);
        vif.clk <= 1'b0;
        #(period_lo * 1ps);
    endtask : drv_clk_cycle

    function void start_clk();
        this.clk_enable = 1;
    endfunction : start_clk

    function void stop_clk();
        this.clk_enable = 0;
    endfunction : stop_clk

endclass : clk_uvc_drv
