//! Syscall interface definitions.

use serde::{Deserialize, Serialize};

/// Well-known syscall numbers.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum SyscallNumber {
    // Process
    Fork = 1,
    Exec = 2,
    Exit = 3,
    WaitPid = 4,
    GetPid = 5,

    // Memory
    Mmap = 10,
    Munmap = 11,
    Brk = 12,

    // File
    Open = 20,
    Close = 21,
    Read = 22,
    Write = 23,
    Ioctl = 24,

    // Network
    Socket = 30,
    Connect = 31,
    Bind = 32,
    Listen = 33,
    Accept = 34,

    // AI-specific
    AiInference = 100,
    AiModelLoad = 101,
    AiModelUnload = 102,
    AiSchedule = 103,
}

/// Syscall argument wrapper.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SyscallArg {
    Int(i64),
    UInt(u64),
    Ptr(usize),
    String(String),
    Buffer(Vec<u8>),
}

/// Syscall result.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SyscallResult {
    Ok(u64),
    Err(u32),
    Bytes(Vec<u8>),
    String(String),
}

/// A syscall request.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Syscall {
    pub number: SyscallNumber,
    pub args: Vec<SyscallArg>,
}

impl Syscall {
    pub fn new(number: SyscallNumber) -> Self {
        Self { number, args: Vec::new() }
    }

    pub fn arg(mut self, arg: SyscallArg) -> Self {
        self.args.push(arg);
        self
    }
}
