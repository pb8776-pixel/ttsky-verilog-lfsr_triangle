# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 ns (100 MHz)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 0
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    dut.ena.value = 1

    dut._log.info("Release reset, starting LFSR...")

    # Expected LFSR sequence generator (software model)
    def lfsr_model(state):
        feedback = ( (state >> 7) ^ (state >> 5) ^ (state >> 4) ^ (state >> 3) ) & 1
        return ((state << 1) & 0xFF) | feedback

    # Initialize with same seed as RTL (0x01)
    expected_state = 0x01

    # Run for 20 cycles to check correctness
    for cycle in range(20):
        await ClockCycles(dut.clk, 1)
        dut_val = int(dut.uo_out.value)

        dut._log.info(f"Cycle {cycle:02d}: DUT={dut_val:02X}, Expected={expected_state:02X}")
        assert dut_val == expected_state, f"Mismatch at cycle {cycle}: DUT={dut_val:02X}, Expected={expected_state:02X}"

        # Update expected state
        expected_state = lfsr_model(expected_state)
