//! Hardware Abstraction Layer (HAL) interface.
//!
//! Defines traits for hardware interaction, enabling portable kernel code.

use serde::{Deserialize, Serialize};

/// CPU information.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CpuInfo {
    pub vendor: String,
    pub model: String,
    pub cores: u32,
    pub frequency_mhz: u32,
    pub features: Vec<String>,
}

/// Memory information.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemoryInfo {
    pub total_bytes: u64,
    pub available_bytes: u64,
    pub used_bytes: u64,
}

/// Display mode.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DisplayMode {
    pub width: u32,
    pub height: u32,
    pub refresh_rate: u32,
    pub bpp: u32,
}

/// HAL trait — platform-specific implementation.
pub trait Hal {
    fn cpu_info(&self) -> CpuInfo;
    fn memory_info(&self) -> MemoryInfo;
    fn current_time_ns(&self) -> u64;
    fn sleep_ns(&self, ns: u64);
    fn display_modes(&self) -> Vec<DisplayMode>;
}
