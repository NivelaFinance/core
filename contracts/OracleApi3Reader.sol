// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title Interface of the proxy contract that is used to read a specific API3
/// data feed
/// @notice While reading API3 data feeds, users are strongly recommended to
/// use this interface to interact with data feed-specific proxy contracts,
/// rather than accessing the underlying contracts directly
interface IApi3ReaderProxy {
    /// @notice Returns the current value and timestamp of the API3 data feed
    /// associated with the proxy contract
    /// @dev The user is responsible for validating the returned data. For
    /// example, if `value` is the spot price of an asset, it would be
    /// reasonable to reject values that are not positive.
    /// `timestamp` does not necessarily refer to a timestamp of the chain that
    /// the read proxy is deployed on. Considering that it may refer to an
    /// off-chain time (such as the system time of the data sources, or the
    /// timestamp of another chain), the user should not expect it to be
    /// strictly bounded by `block.timestamp`.
    /// Considering that the read proxy contract may be upgradeable, the user
    /// should not assume any hard guarantees about the behavior in general.
    /// For example, even though it may sound reasonable to expect `timestamp`
    /// to never decrease over time and the current implementation of the proxy
    /// contract guarantees it, technically, an upgrade can cause `timestamp`
    /// to decrease. Therefore, the user should be able to handle any change in
    /// behavior, which may include reverting gracefully.
    /// @return value Data feed value
    /// @return timestamp Data feed timestamp
    function read() external view returns (int224 value, uint32 timestamp);
}
pragma solidity >=0.8.24 <0.9.0;

/// @title OracleApi3Reader
/// @notice A contract that reads price data from API3's oracle proxy
/// @dev Implements a Chainlink-compatible interface while using API3's data feed
contract OracleApi3Reader {
    /// @notice The address of the API3 proxy contract
    address public proxy;

    /// @notice Initializes the contract with the API3 proxy address
    /// @param proxy_ The address of the API3 proxy contract to read from
    constructor(address proxy_) {
        proxy = proxy_;
    }

    /// @notice Gets the latest price data in a Chainlink-compatible format
    /// @return roundId Always returns 0 as API3 doesn't use round IDs
    /// @return answer The latest price value from the oracle
    /// @return startedAt Always returns 0 as API3 doesn't use this field
    /// @return updatedAt The timestamp of the latest price update
    /// @return answeredInRound Always returns 0 as API3 doesn't use round IDs
    function latestRoundData()
        public
        view
        virtual
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        (int224 value, uint32 timestamp) = IApi3ReaderProxy(proxy).read();
        return (0, int256(value), 0, uint256(timestamp), 0);
    }

    /// @notice Returns the number of decimal places in the oracle's price data
    /// @return The number of decimal places (18)
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}