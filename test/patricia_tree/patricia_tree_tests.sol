pragma solidity ^0.4.16;
pragma experimental "v0.5.0";
pragma experimental "ABIEncoderV2";

//import {Bits} from "../../bits/Bits.sol";
import {Data} from "../../src/patricia_tree/Data.sol";
import {PatriciaTreeImpl} from "../../src/patricia_tree/PatriciaTreeImpl.sol";
import {STLTest} from "../STLTest.sol";

// TODO seems testing here is a bit over the top.

/*******************************************************/

contract PatriciaUtilsTest is STLTest {

    using Data for Data.Node;
    using Data for Data.Edge;
    using Data for Data.Label;
    
    uint constant MAX_LENGTH = 256;
    uint constant UINT256_ZEROES = 0;
    uint constant UINT256_ONES = ~uint(0);
    bytes32 constant B32_ZEROES = bytes32(UINT256_ZEROES);
    bytes32 constant B32_ONES = bytes32(UINT256_ONES);
}


contract PatriciaTreeTest is STLTest, PatriciaTreeImpl {}

/*******************************************************/

contract TestPatriciaUtilsChopFirstBitThrowsLengthIsZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l;
        l.chopFirstBit();
    }
}


contract TestPatriciaUtilsChopFirstBitZeroes is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 256);
        uint bit;
        for(uint i = 1; i <= 256; i++) {
            (bit, l) = l.chopFirstBit();
            require(bit == 0);
            require(l.data == B32_ZEROES);
            require(l.length == MAX_LENGTH - i);
        }
    }
}


contract TestPatriciaUtilsChopFirstBitOnes is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 256);
        uint bit;
        for(uint i = 1; i <= 256; i++) {
            (bit, l) = l.chopFirstBit();
            require(bit == 1);
            require(l.data == B32_ONES << i);
            require(l.length == MAX_LENGTH - i);
        }
    }
}


contract TestPatriciaUtilsChopFirstBitDoesNotMutate is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 256);
        l.chopFirstBit();
        require(l.data == B32_ONES);
        require(l.length == 256);
    }
}


contract TestPatriciaUtilsRemovePrefixThrowsLessLengthZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l;
        l.removePrefix(1);
    }
}


contract TestPatriciaUtilsRemovePrefixThrowsLessLengthNonZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 5);
        l.removePrefix(6);
    }
}


contract TestPatriciaUtilsRemoveZeroPrefixLengthZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 0);
        l = l.removePrefix(0);
        require(l.data == B32_ONES);
        require(l.length == 0);
    }
}


contract TestPatriciaUtilsRemoveZeroPrefixLength256 is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 256);
        l = l.removePrefix(0);
        require(l.data == B32_ONES);
        require(l.length == 256);
    }
}


contract TestPatriciaUtilsRemoveFullPrefixLength256 is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 256);
        l = l.removePrefix(256);
        require(l.data == B32_ZEROES);
        require(l.length == 0);
    }
}


contract TestPatriciaUtilsRemovePrefix is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(hex"ef1230", 20);
        l = l.removePrefix(4);
        require(l.length == 16);
        require(l.data == hex"f123");
        l = l.removePrefix(15);
        require(l.length == 1);
        require(l.data == hex"80");
        l = l.removePrefix(1);
        require(l.length == 0);
        require(l.data == 0);
    }
}


contract TestPatriciaUtilsRemovePrefixOnes is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 256);
        for(uint i = 1; i <= 256; i++) {
            l = l.removePrefix(1);
            require(l.data == B32_ONES << i);
            require(l.length == MAX_LENGTH - i);
        }
    }
}


contract TestPatriciaUtilsRemovePrefixDoesNotMutate is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(hex"ef1230", 20);
        l.removePrefix(4);
        require(l.data == hex"ef1230");
        require(l.length == 20);
    }
}


contract TestPatriciaUtilsCommonPrefixOfZeroLengthLabelsIsZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a;
        Data.Label memory b;
        require(a.commonPrefix(b) == 0);
    }
}


contract TestPatriciaUtilsCommonPrefixOfNonZeroAndZeroLabelIsZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(B32_ONES, 256);
        Data.Label memory b;
        require(a.commonPrefix(b) == 0);
    }
}


contract TestPatriciaUtilsCommonPrefixOfLabelWithItselfIsLabelLength is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(B32_ONES, 164);
        require(a.commonPrefix(a) == 164);
    }
}




contract TestPatriciaUtilsSplitAtThrowsPosGreaterThanLength is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 0);
        l.splitAt(1);
    }
}


contract TestPatriciaUtilsSplitAtThrowsPosGreaterThan256 is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 0);
        l.splitAt(257);
    }
}


contract TestPatriciaUtilsSplitAtPosEqualToLengthDoesntFail is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 2);
        l.splitAt(2);
    }
}


contract TestPatriciaUtilsSplitAtPosEqualTo256DoesntFail is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ZEROES, 256);
        l.splitAt(256);
    }
}

contract TestPatriciaUtilsSplitAtDoesntMutate is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 55);
        l.splitAt(43);
        require(l.data == B32_ONES);
        require(l.length == 55);
    }
}


contract TestPatriciaUtilsSplitAtZero is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory l = Data.Label(B32_ONES, 55);
        var (pre, suf) = l.splitAt(0);
        require(pre.data == B32_ZEROES);
        require(pre.length == 0);
        require(suf.data == B32_ONES);
        require(suf.length == 55);
    }
}


contract TestPatriciaUtilsSplitAt is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(hex"abcd", 16);

        var (x, y) = a.splitAt(0);
        require(x.length == 0);
        require(y.length == a.length);
        require(y.data == a.data);

        (x, y) = a.splitAt(4);
        require(x.length == 4);
        require(x.data == hex"a0");
        require(y.length == 12);
        require(y.data == hex"bcd0");

        (x, y) = a.splitAt(16);
        require(y.length == 0);
        require(x.length == a.length);
        require(x.data == a.data);
    }
}


contract TestPatriciaUtilsSplitCommonPrefixDoesNotMutate is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(hex"abcd", 16);
        Data.Label memory b = Data.Label(hex"a0f570", 20);
        a.splitCommonPrefix(b);

        require(a.data == hex"abcd");
        require(a.length == 16);
        require(b.data == hex"a0f570");
        require(b.length == 20);
    }
}


contract TestPatriciaUtilsSplitCommonPrefixWithItself is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(hex"abcd", 16);
        var (pre, suf) = a.splitCommonPrefix(a);
        require(pre.data == a.data);
        require(pre.length == a.length);

        require(suf.data == B32_ZEROES);
        require(suf.length == 0);
    }
}

contract TestPatriciaUtilsSplitCommonPrefixWithZeroLabel is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(B32_ZEROES, 0);
        Data.Label memory b = Data.Label(hex"a0f570", 20);
        var (pre, suf) = a.splitCommonPrefix(b);

        require(pre.data == B32_ZEROES);
        require(pre.length == 0);
        require(suf.data == a.data);
        require(suf.length == a.length);
    }
}

contract TestPatriciaUtilsSplitCommonPrefixWithZeroCheck is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(B32_ZEROES, 0);
        Data.Label memory b = Data.Label(hex"a0f570", 20);
        var (pre, suf) = b.splitCommonPrefix(a);

        require(pre.data == B32_ZEROES);
        require(pre.length == 0);
        require(suf.data == b.data);
        require(suf.length == b.length);
    }
}

contract TestPatriciaUtilsSplitCommonPrefix is PatriciaUtilsTest {
    function testImpl() internal {
        Data.Label memory a = Data.Label(hex"abcd", 16);
        Data.Label memory b = Data.Label(hex"a0f570", 20);

        var (prefix, suffix) = b.splitCommonPrefix(a);
        require(prefix.length == 4);
        require(prefix.data == hex"a0");
        require(suffix.length == 16);
        require(suffix.data == hex"0f57");
    }
}

/*******************************************************/

// These tests has a storage check as part of the validation.

contract TestPatriciaTreeInsert is PatriciaTreeTest {
    function testImpl() internal {

        bytes memory keyBts = "val";
        bytes memory valBts = "VAL";
        bytes32 keyHash = keccak256(keyBts); // 749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11
                bytes32 valHash = keccak256(valBts); // 6a96595ccfcb78ff3e886e67a3c94a0c6c8fe147c51512c4f9b5e8aa8d636f07

        insert("val", "VAL");

        assert(rootEdge.node == valHash);
        assert(rootEdge.label.data == keyHash);
        assert(rootEdge.label.length == 256);
    }
}

contract TestPatriciaTreeInsertTwo is PatriciaTreeTest {
    function testImpl() internal {
        bytes memory keyBts = "val";
        bytes memory valBts = "VAL";
        bytes memory key2Bts = "val2";
        bytes memory val2Bts = "VAL2";

        bytes32 keyHash = keccak256(keyBts); // 749eb9a32604a1e3d5563e475f22a54221a22999f274fb5acd84a00d16053a11
        bytes32 valHash = keccak256(valBts); // 6a96595ccfcb78ff3e886e67a3c94a0c6c8fe147c51512c4f9b5e8aa8d636f07
        bytes32 key2Hash = keccak256(key2Bts); // 0f70e93237e6edac092d1573b606d68d672d920b51559399f352166ae4b4a727
        bytes32 val2Hash = keccak256(val2Bts); // 780f7d9be6b7b221c27f7d5e84ff9ff220b60283dd7d012fbd9195bb6bb472aa

        insert("val", "VAL");
        insert("val2", "VAL2");

        var node = nodes[rootEdge.node];
        var c0 = node.children[0];
        var c1 = node.children[1];

        assert(rootEdge.label.length == 1);
        assert(c0.node == val2Hash);
        assert(c0.label.length == 254);
        assert(c1.node == valHash);
        assert(c1.label.length == 254);
    }
}


contract TestPatriciaTreeInsertOrderDoesNotMatter is STLTest {
    function testImpl() internal {
        var pt1 = new PatriciaTreeImpl();
        var pt2 = new PatriciaTreeImpl();
        pt1.insert("testkey", "testval");
        pt1.insert("testkey2", "testval2");
        pt1.insert("testkey3", "testval3");
        pt1.insert("testkey4", "testval4");
        pt1.insert("testkey5", "testval5");

        pt2.insert("testkey2", "testval2");
        pt2.insert("testkey", "testval");
        pt2.insert("testkey5", "testval5");
        pt2.insert("testkey3", "testval3");
        pt2.insert("testkey4", "testval4");

        assert(pt1.root() == pt2.root());
    }
}
