pragma solidity ^0.8.0;

contract BankingSystem {
    address public admin;

    struct Customer {
        string name;
        uint balance;
        bool exists;
    }

    mapping(address => Customer) public customers;

    event CustomerRegistered(address indexed customerAddress, string name);
    event Deposit(address indexed customerAddress, uint amount);
    event Withdrawal(address indexed customerAddress, uint amount);
    event LoanRequested(address indexed customerAddress, uint amount);
    event LoanRepaid(address indexed customerAddress, uint amount);
    event PenaltyEnforced(address indexed customerAddress, uint amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerCustomer(address customerAddress, string memory name) external onlyAdmin {
        require(!customers[customerAddress].exists, "Customer already registered");
        customers[customerAddress] = Customer(name, 0, true);
        emit CustomerRegistered(customerAddress, name);
    }

    function deposit() external payable {
        require(customers[msg.sender].exists, "Customer not registered");
        customers[msg.sender].balance += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) external {
        require(customers[msg.sender].exists, "Customer not registered");
        require(customers[msg.sender].balance >= amount, "Insufficient balance");
        customers[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function requestLoan(uint amount) external {
        require(customers[msg.sender].exists, "Customer not registered");
        require(customers[msg.sender].balance >= amount, "Insufficient balance for loan");
        customers[msg.sender].balance -= amount;
        emit LoanRequested(msg.sender, amount);
    }

    function repayLoan(uint amount) external {
        require(customers[msg.sender].exists, "Customer not registered");
        require(amount <= customers[msg.sender].balance, "Insufficient balance to repay");
        customers[msg.sender].balance -= amount;
        emit LoanRepaid(msg.sender, amount);
    }

    function enforcePenalty(address customerAddress, uint amount) external onlyAdmin {
        require(customers[customerAddress].exists, "Customer not registered");
        require(amount <= customers[customerAddress].balance, "Insufficient balance for penalty");
        customers[customerAddress].balance -= amount;
        emit PenaltyEnforced(customerAddress, amount);
    }
}
