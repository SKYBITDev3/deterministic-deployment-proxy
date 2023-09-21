object "Proxy" {
	// deployment code
	code {
		let size := datasize("runtime")
		datacopy(0, dataoffset("runtime"), size)
		return(0, size)
	}
	object "runtime" {
		// deployed code
		code {
            mstore(0, caller()) // 32 bytes. The user's address.
            mstore(0x20, calldataload(0)) // 32 bytes. User-provided salt.
            let callerAndSaltHash := keccak256(0, 0x40) // hash caller with salt to help ensure unique address, prevent front-running. It's cheaper to take whole slots (include padded 0s). Store result on stack.

			calldatacopy(0, 32, sub(calldatasize(), 32))
			let result := create2(callvalue(), 0, sub(calldatasize(), 32), callerAndSaltHash)
			if iszero(result) { revert(0, 0) }
			mstore(0, result)
			return(12, 20)
		}
	}
}
