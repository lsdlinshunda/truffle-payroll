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
    uint totalSalary;
    uint totalEmployee;
    address[] employeeList;

    mapping(address => Employee) public employees;
    
    event NewEmployee(
        address employee
    );
    event UpdateEmployee(
        address employee
    );
    event RemoveEmployee(
        address employee
    );
    event NewFund(
        uint balance
    );
    event GetPaid(
        address employee
    );

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
    
    //[BUG] 不刷新页面时能连续添加同一address
    function addEmployee(address employeeId, uint salary) onlyOwner employeeNoExist(employeeId) {
        salary = salary.mul(1 ether);
        employees[employeeId] = Employee(employeeId,salary,now);
        totalSalary = totalSalary.add(salary);
        totalEmployee = totalEmployee.add(1);
        employeeList.push(employeeId);
        NewEmployee(employeeId);
    }
    
    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        _partialPaid(employees[employeeId]);
        totalSalary = totalSalary.sub(employees[employeeId].salary);
        delete employees[employeeId];
        totalEmployee = totalEmployee.sub(1);
        for (uint i=0;i<totalEmployee;++i) {
            if (employeeList[i] == employeeId) {
                employeeList[i] = employeeList[totalEmployee];
                break;
            }
        }
        delete employeeList[totalEmployee];
        employeeList.length = employeeList.length.sub(1);
        RemoveEmployee(employeeId);
    }
    
    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        _partialPaid(employees[employeeId]);
        salary = salary.mul(1 ether);
        totalSalary = totalSalary.sub(employees[employeeId].salary).add(salary);
        employees[employeeId].salary = salary;
        employees[employeeId].lastPayday = now;
        UpdateEmployee(employeeId);
    }
    
    function addFund() payable returns (uint){
        NewFund(this.balance);
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
    
    function checkEmployee(uint index) returns (address employeeId, uint salary, uint lastPayday) {
        employeeId = employeeList[index];
        var employee = employees[employeeId];
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }
    
    function checkEmployeeByAddress(address employeeId) returns(uint salary, uint lastPayday) {
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
        GetPaid(employee.id);
    }

    function checkInfo() returns(uint balance, uint runway, uint employeeCount) {
        balance = this.balance;
        runway = totalSalary > 0 ? calculateRunway() : 0;
        employeeCount = totalEmployee;
    }
    
}
