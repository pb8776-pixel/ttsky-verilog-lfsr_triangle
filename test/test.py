# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

# Expected 8-bit maximal-length LFSR sequence starting from 0x01
EXPECTED_SEQ = [
    0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80,
    0x81, 0x03, 0x06, 0x0C, 0x18, 0x30, 0x60, 0xC0
]

@cocotb.test()
async def test_lfsr(dut):
    """Test the 8-bit maximal-length LFSR for first 16 cycles."""

    # Start clock
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())

    # Apply reset
    dut.rst_n.value = 0
    dut.ena.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rst_n.value = 1
    dut.ena.value = 1

    # Wait one cycle for LFSR output to stabilize
    await RisingEdge(dut.clk)

    # Check first 16 cycles
    for cycle, expected in enumerate(EXPECTED_SEQ):
        dut_val = int(dut.uo_out.value)
        assert dut_val == expected, f"Cycle {cycle}: DUT={dut_val:02X}, Expected={expected:02X}"
        await RisingEdge(dut.clk)
