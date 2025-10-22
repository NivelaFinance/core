// SPDX-License-Identifier: MIT

pragma solidity >=0.8.24 <0.9.0;

/**
 * @title Context
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, as when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 * @notice This contract is used through inheritance. It will make available the
 * modifier `_msgSender()`, which can be used to reference the account that
 * called a function within an implementing contract.
 */
abstract contract Context {
    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Gets the sender of the current call
     * @dev Provides a way to retrieve the message sender that supports meta-transactions
     * @return Sender address (msg.sender in the base implementation)
     */
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    /**
     * @notice Gets the complete calldata of the current call
     * @dev Provides a way to retrieve the message data that supports meta-transactions
     * @return Complete calldata bytes
     */
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @notice Gets the length of any context-specific suffix in the message data
     * @dev Used in meta-transaction implementations to account for additional data
     * @return Length of the context suffix (0 in the base implementation)
     */
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title Ownable
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 * @notice By default, the owner account will be the one that deploys the contract.
 * This can later be changed with {transferOwnership} and {renounceOwnership}.
 */
abstract contract Ownable is Context {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    /// @notice Address of the current owner
    address private _owner;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when ownership is transferred
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Thrown when non-owner tries to call owner-only function
    error UnauthorizedAccount(address account);
    /// @notice Thrown when trying to transfer ownership to invalid address
    error InvalidOwner(address owner);
    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Throws if called by any account other than the owner
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Initializes the contract setting the deployer as the initial owner
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Leaves the contract without owner
     * @dev Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @notice Transfers ownership of the contract to a new account
     * @dev The new owner cannot be the zero address
     * @param newOwner The address that will become the new owner
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert InvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Returns the address of the current owner
     * @return Current owner address
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`)
     * Internal function without access restriction
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Throws if the sender is not the owner
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert UnauthorizedAccount(_msgSender());
        }
    }
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20Custom
 * @dev Interface for the ERC20 fungible token standard (EIP-20)
 * @notice Defines functionality for:
 * 1. Token transfers
 * 2. Allowance management
 * 3. Balance tracking
 * 4. Token metadata
 */
interface IERC20Custom {
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Emitted on token transfer between addresses
     * @param from Source address (0x0 for mints)
     * @param to Destination address (0x0 for burns)
     * @param value Amount of tokens transferred
     * @notice Tracks:
     * · Regular transfers
     * · Minting operations
     * · Burning operations
     */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /**
     * @dev Emitted when spending allowance is granted
     * @param owner Address granting permission
     * @param spender Address receiving permission
     * @param value Amount of tokens approved
     * @notice Records:
     * · New approvals
     * · Updated allowances
     * · Revoked permissions
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /*//////////////////////////////////////////////////////////////
                        TRANSFER OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Transfers tokens to specified recipient
     * @param to Recipient address
     * @param value Amount to transfer in base units
     * @return bool True if transfer succeeds
     * @dev Requirements:
     * · Caller has sufficient balance
     * · Recipient is valid
     * · Amount > 0
     *
     * Effects:
     * · Decreases caller balance
     * · Increases recipient balance
     * · Emits Transfer event
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @notice Executes transfer on behalf of token owner
     * @param from Source address
     * @param to Destination address
     * @param value Amount to transfer in base units
     * @return bool True if transfer succeeds
     * @dev Requirements:
     * · Caller has sufficient allowance
     * · Source has sufficient balance
     * · Valid addresses
     *
     * Effects:
     * · Decreases allowance
     * · Updates balances
     * · Emits Transfer event
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    /*//////////////////////////////////////////////////////////////
                        APPROVAL OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Authorizes address to spend tokens
     * @param spender Address to authorize
     * @param value Amount to authorize in base units
     * @return bool True if approval succeeds
     * @dev Controls:
     * · Spending permissions
     * · Delegation limits
     * · Authorization levels
     *
     * Security:
     * · Overwrites previous allowance
     * · Requires explicit value
     * · Emits Approval event
     */
    function approve(address spender, uint256 value) external returns (bool);

    /*//////////////////////////////////////////////////////////////
                            TOKEN METADATA
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves human-readable token name
     * @return string Full token name
     */
    function name() external view returns (string memory);

    /**
     * @notice Retrieves token trading symbol
     * @return string Short token identifier
     */
    function symbol() external view returns (string memory);

    /**
     * @notice Retrieves token decimal precision
     * @return uint8 Number of decimal places
     * @dev Standard:
     * · 18 for most tokens
     * · Used for display formatting
     */
    function decimals() external view returns (uint8);

    /*//////////////////////////////////////////////////////////////
                            BALANCE QUERIES
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves total token supply
     * @return uint256 Current total supply
     * @dev Reflects:
     * · All minted tokens
     * · Minus burned tokens
     * · In base units
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice Retrieves account token balance
     * @param account Address to query
     * @return uint256 Current balance in base units
     * @dev Returns:
     * · Available balance
     * · Includes pending rewards
     * · Excludes locked tokens
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice Retrieves remaining spending allowance
     * @param owner Token owner address
     * @param spender Authorized spender address
     * @return uint256 Current allowance in base units
     * @dev Shows:
     * · Approved amount
     * · Remaining limit
     * · Delegation status
     */
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20Errors
 * @dev Standardized error interface for ERC20 token operations
 * @notice Defines functionality for:
 * 1. Balance validation errors
 * 2. Address validation errors
 * 3. Allowance validation errors
 */
interface IERC20Errors {
    /*//////////////////////////////////////////////////////////////
                        BALANCE ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for insufficient token balance
     * @param sender Address attempting the transfer
     * @param balance Current balance of sender
     * @param needed Amount attempting to transfer
     * @notice Triggered when:
     * · Transfer amount > balance
     * · Burn amount > balance
     * · Withdrawal > available
     */
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );
    /*//////////////////////////////////////////////////////////////
                        ADDRESS VALIDATION ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for invalid sending address
     * @param sender Address that failed validation
     * @notice Triggered when:
     * · Sender is zero address
     * · Sender is blacklisted
     * · Sender lacks permissions
     */
    error ERC20InvalidSender(address sender);
    /**
     * @dev Error for invalid receiving address
     * @param receiver Address that failed validation
     * @notice Triggered when:
     * · Receiver is zero address
     * · Receiver is blacklisted
     * · Receiver is contract without implementation
     */
    error ERC20InvalidReceiver(address receiver);
    /*//////////////////////////////////////////////////////////////
                        ALLOWANCE ERRORS
    //////////////////////////////////////////////////////////////*/
    /**
     * @dev Error for insufficient spending allowance
     * @param spender Address attempting to spend
     * @param allowance Current approved amount
     * @param needed Amount attempting to spend
     * @notice Triggered when:
     * · Spend amount > allowance
     * · Transfer amount > approved
     * · Delegation exceeds limits
     */
    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );
    /**
     * @dev Error for invalid approving address
     * @param approver Address that failed validation
     * @notice Triggered when:
     * · Approver is zero address
     * · Approver lacks permissions
     * · Approver is invalid state
     */
    error ERC20InvalidApprover(address approver);
    /**
     * @dev Error for invalid spending address
     * @param spender Address that failed validation
     * @notice Triggered when:
     * · Spender is zero address
     * · Spender is blacklisted
     * · Spender lacks permissions
     */
    error ERC20InvalidSpender(address spender);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title IERC20TokenRebase
 * @dev Extended interface for ERC20 tokens with elastic supply and safe management
 * @notice Defines functionality for:
 * 1. Supply elasticity (rebasing)
 * 2. Safe-based token management
 * 3. Supply control mechanisms
 * 4. Configuration management
 */
interface IERC20TokenRebase is IERC20Custom {
    /*//////////////////////////////////////////////////////////////
                        SUPPLY MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Mints new tokens to specified account
     * @param account Address to receive minted tokens
     * @param amount Quantity of tokens to mint in base units
     * @dev Requires:
     * · Caller is authorized minter
     * · Within maxSupply limits
     * · Valid recipient
     */
    function mint(address account, uint256 amount) external;

    /**
     * @notice Burns tokens from specified account
     * @param account Address to burn tokens from
     * @param amount Quantity of tokens to burn in base units
     * @dev Requires:
     * · Caller is authorized
     * · Account has sufficient balance
     * · Amount > 0
     */
    function burn(address account, uint256 amount) external;

    /*//////////////////////////////////////////////////////////////
                        REBASE OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Executes supply rebase based on current parameters
     * @dev Triggers:
     * · Supply adjustment
     * · Balance recalculation
     * · Event emission
     *
     * Considers:
     * · Rebase interval
     * · Basis points
     * · Supply limits
     */
    function rebase() external;

    /**
     * @notice Configures rebase parameters
     * @param rebaseInterval Time period between rebases (in seconds)
     * @param rebaseBasisPoints Scale factor for rebase (in basis points)
     * @dev Controls:
     * · Rebase frequency
     * · Rebase magnitude
     * · Supply elasticity
     */
    function setRebaseConfig(
        uint256 rebaseInterval,
        uint256 rebaseBasisPoints
    ) external;

    /*//////////////////////////////////////////////////////////////
                        SAFE MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes new token management safe
     * @param safe Address of safe to create
     * @dev Establishes:
     * · Safe permissions
     * · Access controls
     * · Management capabilities
     */
    function createSafe(address safe) external;

    /**
     * @notice Removes existing token management safe
     * @param safe Address of safe to remove
     * @dev Handles:
     * · Permission revocation
     * · State cleanup
     * · Access termination
     */
    function destroySafe(address safe) external;

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Retrieves floor contract address
     * @return address Active floor contract
     * @dev Used for:
     * · Price stability
     * · Supply control
     */
    function floor() external view returns (address);

    /**
     * @notice Retrieves authorized minter address
     * @return address Active minter contract
     * @dev Controls:
     * · Mint permissions
     * · Supply expansion
     */
    function minter() external view returns (address);

    /**
     * @notice Returns absolute maximum token supply
     * @return uint256 Maximum supply cap in base units
     * @dev Enforces:
     * · Hard supply limit
     * · Mint restrictions
     */
    function maxSupply() external view returns (uint256);

    /**
     * @notice Calculates maximum supply after rebase
     * @return uint256 Post-rebase maximum supply in base units
     * @dev Considers:
     * · Current max supply
     * · Rebase parameters
     * · Supply caps
     */
    function maxSupplyRebased() external view returns (uint256);

    /**
     * @notice Calculates total supply after rebase
     * @return uint256 Post-rebase total supply in base units
     * @dev Reflects:
     * · Current supply
     * · Rebase effects
     * · Supply limits
     */
    function totalSupplyRebased() external view returns (uint256);
}
pragma solidity >=0.8.24 <0.9.0;

/**
 * @title NIV Token
 * @dev Advanced rebase token with dynamic supply management
 * @notice Elastic supply token with configurable rebase mechanics
 */
contract NIV is Context, Ownable, IERC20TokenRebase, IERC20Errors {
    /*//////////////////////////////////////////////////////////////
                        TOKEN METADATA
    //////////////////////////////////////////////////////////////*/
    /// @notice Token name
    string private _name;
    /// @notice Token symbol
    string private _symbol;
    /// @notice Token decimal places
    uint8 private immutable _decimals;
    /*//////////////////////////////////////////////////////////////
                        SUPPLY MANAGEMENT
    //////////////////////////////////////////////////////////////*/
    /// @notice Maximum possible token supply
    /// @dev Prevents unlimited token creation
    uint256 private immutable _maxSupply;
    /// @notice Current total token supply
    uint256 private _totalSupply;
    /// @notice Total supply in normal mode
    /// @dev Scaled by normalDivisor
    uint256 private _normalSupply;
    /// @notice Total supply in safe mode
    /// @dev Scaled by SAFE_DIVISOR
    uint256 private _safeSupply;
    /// @notice Remaining supply that can be burned
    uint256 public maxSupplyBurned;
    /// @notice Maximum rebased supply
    uint256 public maxSupplyRebased;
    /// @notice Next scheduled rebase timestamp
    uint256 public nextRebaseTime;
    /// @notice Divisor for normal balance calculations
    uint256 public normalDivisor = 1e8;
    /// @notice Rebase percentage in basis points
    uint256 public rebaseBasisPoints = 21;
    /// @notice Interval between rebase operations
    uint256 public rebaseInterval = 21 minutes;
    /*//////////////////////////////////////////////////////////////
                            REBASE CONSTANTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Minimum allowed rebase interval
    uint256 public constant MIN_REBASE_INTERVAL = 21 minutes;
    /// @notice Maximum allowed rebase interval
    uint256 public constant MAX_REBASE_INTERVAL = 21 days;
    /// @notice Maximum number of intervals processed in a single rebase
    uint256 public constant MAX_INTERVALS_PER_REBASE = 7;
    /// @notice Maximum allowed rebase basis points
    uint256 public constant MAX_REBASE_BASIS_POINTS = 21;
    /// @notice Maximum allowed normal divisor
    uint256 public constant MAX_NORMAL_DIVISOR = 1e42;
    /// @notice Fixed divisor for safe mode balances
    uint256 public constant SAFE_DIVISOR = 1e8;
    /// @notice Precision constant for calculations with 10,000 as the base unit
    uint256 public constant TENK_PRECISION = 10_000;
    /*//////////////////////////////////////////////////////////////
                        PROTOCOL ADDRESSES
    //////////////////////////////////////////////////////////////*/
    /// @notice Address responsible for floor price operations
    address public floor;
    /// @notice Address authorized to mint tokens
    address public minter;
    /*//////////////////////////////////////////////////////////////
                        USER STATE TRACKING
    //////////////////////////////////////////////////////////////*/
    /// @notice User token balances
    /// @dev Balances are scaled based on mode (normal/safe)
    mapping(address => uint256) private _balances;
    /// @notice Token spending allowances
    /// @dev Nested mapping of owner → spender → allowance
    mapping(address => mapping(address spender => uint256)) private _allowances;
    /// @notice Tracks addresses in safe mode
    mapping(address => bool) private _safes;
    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    /// @notice Emitted when rebase basis points are changed
    event RebaseBasisPointsChanged(uint256 rebaseBasisPoints);
    /// @notice Emitted when rebase interval is modified
    event RebaseIntervalChanged(uint256 rebaseInterval);
    /// @notice Emitted when tokens are toasted (burned)
    event Toast(address indexed toaster, uint256 value, uint256 maxSupply);
    /// @notice Emitted when a safe is created for an address
    event SafeCreated(address indexed safe);
    /// @notice Emitted when a safe is destroyed
    event SafeDestroyed(address indexed safe);
    /// @notice Emitted when the divisor is updated during rebase
    event DivisorUpdated(uint256 newDivisor);
    /*//////////////////////////////////////////////////////////////
                            CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/
    /// @notice Thrown when a zero address is provided
    error ZeroAddress();
    /// @notice Thrown when an operation is attempted on a non-safe address
    error NotASafe();
    /// @notice Thrown when attempting to create a safe for an existing safe
    error AlreadyASafe();
    /// @notice Thrown when rebase interval is below minimum
    error RebaseIntervalBelowLimit();
    /// @notice Thrown when rebase interval exceeds maximum
    error RebaseIntervalAboveLimit();
    /// @notice Thrown when rebase basis points exceed maximum
    error RebaseBasisPointsAboveLimit();
    /// @notice Thrown when max supply would be exceeded
    error MaxSupplyReached();
    /// @notice Thrown when minter is already set
    error MinterAlreadySet();
    /// @notice Thrown when floor address is already set
    error FloorAlreadySet();
    /**
     * @notice Access control modifier
     */
    modifier onlyMinter() {
        if (address(minter) != _msgSender()) {
            revert UnauthorizedAccount(_msgSender());
        }
        _;
    }
    /**
     * @notice Access control modifier
     */
    modifier onlyFloor() {
        if (address(floor) != _msgSender()) {
            revert UnauthorizedAccount(_msgSender());
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Initializes the NIV token
     * @param name_ Token name
     * @param symbol_ Token symbol
     * @param decimals_ Token decimal places
     * @param maxSupply_ Maximum token supply
     *
     * @dev Sets initial token configuration and prepares first rebase
     *
     * Requirements:
     * · Non-zero token metadata
     *
     * Effects:
     * · Sets token metadata
     * · Initializes supply tracking
     * · Sets first rebase time
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 maxSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _maxSupply = maxSupply_;
        maxSupplyBurned = maxSupply_;
        maxSupplyRebased = maxSupply_;
        _setNextRebaseTime();
    }

    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Sets the minter address
     * @param minter_ Address authorized to mint tokens
     *
     * Requirements:
     * · Only callable by owner
     * · Non-zero address
     * · Minter not previously set
     *
     * Effects:
     * · Sets minter address
     */
    function setMinter(address minter_) external onlyOwner {
        if (minter != address(0)) revert MinterAlreadySet();
        _ensureNonzeroAddress(minter_);
        minter = minter_;
    }

    /**
     * @notice Sets the floor address
     * @param floor_ Address responsible for floor operations
     *
     * Requirements:
     * · Only callable by owner
     * · Non-zero address
     * · Floor not previously set
     *
     * Effects:
     * · Sets floor address
     */
    function setFloor(address floor_) external onlyOwner {
        if (floor != address(0)) revert FloorAlreadySet();
        _ensureNonzeroAddress(floor_);
        floor = floor_;
    }

    /*//////////////////////////////////////////////////////////////
                        CORE TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice Mints new tokens
     * @param to Recipient address
     * @param value Amount of tokens to mint
     *
     * Requirements:
     * · Only callable by minter
     * · Within max supply limit
     *
     * Effects:
     * · Increases total supply
     * · Increases recipient balance
     */
    function mint(address to, uint256 value) external onlyMinter {
        if (_maxSupply != 0 && _totalSupply + value > _maxSupply) {
            revert MaxSupplyReached();
        }
        if (to == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(address(0), to, value);
    }

    /**
     * @notice Burns tokens
     * @param from Address to burn tokens from
     * @param value Amount of tokens to burn
     *
     * Requirements:
     * · Only callable by floor address
     *
     * Effects:
     * · Decreases total supply
     * · Decreases sender balance
     * · Updates max supply burned
     */
    function burn(address from, uint256 value) external onlyFloor {
        maxSupplyBurned -= value;
        emit Toast(_msgSender(), value, maxSupplyBurned);
        if (from == address(0)) revert ERC20InvalidSender(address(0));
        _update(from, address(0), value);
    }

    /**
     * @notice Triggers a token rebase
     * @dev Adjusts token supply based on configured parameters
     */
    function rebase() external {
        _rebase();
    }

    // Safe management functions
    function createSafe(address addr) external onlyOwner {
        if (_safes[addr]) revert AlreadyASafe();
        _safes[addr] = true;
        uint256 balance = _balances[addr];
        _normalSupply -= balance;
        uint256 safeBalance = (balance * SAFE_DIVISOR) / normalDivisor;
        _balances[addr] = safeBalance;
        _safeSupply += safeBalance;
        emit SafeCreated(addr);
    }

    function destroySafe(address addr) external onlyOwner {
        if (!_safes[addr]) revert NotASafe();
        _safes[addr] = false;
        uint256 balance = _balances[addr];
        _safeSupply -= balance;
        uint256 normalBalance = (balance * normalDivisor) / SAFE_DIVISOR;
        _balances[addr] = normalBalance;
        _normalSupply += normalBalance;
        emit SafeDestroyed(addr);
    }

    // Configuration functions
    function setRebaseConfig(
        uint256 rebaseInterval_,
        uint256 rebaseBasisPoints_
    ) external onlyOwner {
        if (rebaseInterval_ < MIN_REBASE_INTERVAL)
            revert RebaseIntervalBelowLimit();
        if (rebaseInterval_ > MAX_REBASE_INTERVAL)
            revert RebaseIntervalAboveLimit();
        if (rebaseBasisPoints_ > MAX_REBASE_BASIS_POINTS)
            revert RebaseBasisPointsAboveLimit();
        rebaseInterval = rebaseInterval_;
        rebaseBasisPoints = rebaseBasisPoints_;
        emit RebaseIntervalChanged(rebaseInterval);
        emit RebaseBasisPointsChanged(rebaseBasisPoints);
    }

    // Standard ERC20 functions
    function transfer(address to, uint256 value) external returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    // View functions
    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address addr) external view returns (uint256) {
        if (_safes[addr]) {
            return _balances[addr] / SAFE_DIVISOR;
        }
        return _balances[addr] / normalDivisor;
    }

    function isSafe(address addr) external view returns (bool) {
        return _safes[addr];
    }

    function maxSupply() external view returns (uint256) {
        return _maxSupply;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function normalSupply() public view returns (uint256) {
        return _normalSupply / normalDivisor;
    }

    function safeSupply() public view returns (uint256) {
        return _safeSupply / SAFE_DIVISOR;
    }

    function totalSupplyRebased() public view returns (uint256) {
        return normalSupply() + safeSupply();
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // Private functions
    function _transfer(address from, address to, uint256 value) private {
        if (from == address(0)) revert ERC20InvalidSender(address(0));
        if (to == address(0)) revert ERC20InvalidReceiver(address(0));
        _update(from, to, value);
        _rebase();
    }

    function _increaseBalance(address to, uint256 value) private {
        if (_safes[to]) {
            uint256 safeValue = value * SAFE_DIVISOR;
            _balances[to] += safeValue;
            _safeSupply += safeValue;
        } else {
            uint256 normalValue = value * normalDivisor;
            _balances[to] += normalValue;
            _normalSupply += normalValue;
        }
    }

    function _update(address from, address to, uint256 value) private {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            uint256 normalizedValue;
            if (_safes[from]) {
                normalizedValue = value * SAFE_DIVISOR;
                if (fromBalance < normalizedValue) {
                    revert ERC20InsufficientBalance(
                        from,
                        fromBalance / SAFE_DIVISOR,
                        value
                    );
                }
                _safeSupply -= normalizedValue;
            } else {
                normalizedValue = value * normalDivisor;
                if (fromBalance < normalizedValue) {
                    revert ERC20InsufficientBalance(
                        from,
                        fromBalance / normalDivisor,
                        value
                    );
                }
                _normalSupply -= normalizedValue;
            }
            unchecked {
                _balances[from] = fromBalance - normalizedValue;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _increaseBalance(to, value);
            }
        }
        emit Transfer(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) private {
        _approve(owner, spender, value, true);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) private {
        if (owner == address(0)) revert ERC20InvalidApprover(address(0));
        if (spender == address(0)) revert ERC20InvalidSpender(address(0));
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function _rebase() private {
        if (block.timestamp < nextRebaseTime) return;
        uint256 intervals = (block.timestamp - nextRebaseTime) /
            rebaseInterval +
            1;
        if (intervals > MAX_INTERVALS_PER_REBASE) {
            intervals = MAX_INTERVALS_PER_REBASE;
        }
        if (rebaseBasisPoints == 0) return;
        uint256 multiplier = (TENK_PRECISION + rebaseBasisPoints) ** intervals;
        uint256 divider = TENK_PRECISION ** intervals;
        uint256 nextDivisor = (normalDivisor * multiplier) / divider;
        if (nextDivisor > MAX_NORMAL_DIVISOR) return;
        _setNextRebaseTime();
        normalDivisor = nextDivisor;
        maxSupplyRebased =
            maxSupplyBurned -
            (_totalSupply - totalSupplyRebased());
        emit DivisorUpdated(nextDivisor);
    }

    function _setNextRebaseTime() private {
        uint256 roundedTime = (block.timestamp / rebaseInterval) *
            rebaseInterval;
        nextRebaseTime = roundedTime + rebaseInterval;
    }

    // Validates that an address is not zero
    function _ensureNonzeroAddress(address addr) private pure {
        if (addr == address(0)) {
            revert ZeroAddress();
        }
    }
}