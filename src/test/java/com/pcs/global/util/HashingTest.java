package com.pcs.global.util;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class HashingTest {

    @Test
    void sha256Hex_returnsLowercaseDeterministicDigest() {
        assertEquals(
                "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
                Hashing.sha256Hex("abc")
        );
    }
}
