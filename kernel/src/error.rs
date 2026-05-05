//! Kernel error types.

use thiserror::Error;

#[derive(Error, Debug)]
pub enum KernelError {
    #[error("Process not found: {pid}")]
    ProcessNotFound { pid: u32 },

    #[error("Insufficient permissions for operation")]
    PermissionDenied,

    #[error("Out of memory: requested {requested} bytes")]
    OutOfMemory { requested: usize },

    #[error("Invalid syscall number: {number}")]
    InvalidSyscall { number: u32 },

    #[error("Hardware error: {message}")]
    Hardware { message: String },

    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
}

pub type KernelResult<T> = Result<T, KernelError>;
