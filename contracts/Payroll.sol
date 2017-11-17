//2017.10.29 by Shunda Lin

pragma solidity ^0.4.14;

import './SafeMath.sol';
import './Ownable.sol';

contract Payroll is Ownable {
    using SafeMath for uint;
    
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }
    
    uint constant payDuration = 10 seconds;
    uint  totalSalary;

    mapping(address => Employee) public employees;
    
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
    modifier employeeNoExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }
    
    modifier checkAuthority(address employeeId) {
        assert (employeeId == msg.sender);
        _;
    }
    
    function Payroll() {
        owner = msg.sender;
        totalSalary = 0;
    }
    
    function _partialPaid(Employee employee) private {
        uint payment = employee.salary.mul(now.sub(employee.lastPayday)).div(payDuration);
        employee.id.transfer(payment);
    }    
    
    function addEmployee(address employeeId, uint salary) onlyOwner employeeNoExist(employeeId) {
        salary = salary.mul(1 ether);
        employees[employeeId] = Employee(employeeId,salary,now);
        totalSalary = totalSalary.add(salary);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        _partialPaid(employees[employeeId]);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        delete employees[employeeId];
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        _partialPaid(employees[employeeId]);
        salary = salary.mul(1 ether);
        totalSalary = totalSalary.sub(employees[employeeId].salary).add(salary);
        employees[employeeId].salary = salary;
        employees[employeeId].lastPayday = now;
    }
    
    function addFund() payable returns (uint){
        return this.balance;
    }
    
    function calculateRunway() returns (uint) {
        return this.balance.div(totalSalary);
    }
    
    function hasEnoughFund() returns (bool) {
        return calculateRunway() > 0;
    }
    
    function checkTotalSalary() returns (uint) {
        return totalSalary;
    }
    
    function checkEmployee(address employeeId) returns(uint salary, uint lastPayday) {
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
    
    function changePaymentAddress(address oldAddr, address newAddr) checkAuthority(oldAddr) employeeExist(oldAddr) employeeNoExist(newAddr) {
        var employee = employees[oldAddr]; 
        employees[newAddr] =  Employee(newAddr,employee.salary,employee.lastPayday);
        delete employees[oldAddr];
    }
    
    function getPaid() employeeExist(msg.sender) {
        var employee = employees[msg.sender];
        uint nextPayDay = employee.lastPayday.add(payDuration);
        assert(nextPayDay < now);
        employees[msg.sender].lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }
}
