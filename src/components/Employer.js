import React, { Component } from 'react'

class Employer extends Component {
    constructor(props) {
        super(props);

        this.state = {
        };
    }

    addFund = () => {
        const {payroll, employer, web3} = this.props;
        payroll.addFund({
            from: employer,
            value: web3.toWei(this.fundInput.value)
        });
    }

    addEmployee = () => {
        const {payroll, employer} = this.props;
        payroll.addEmployee(this.employeeInput.value, parseInt(this.salaryInput.value), {
            from: employer,
            gas: 1000000
        }).then((result) => {
            alert('success');
        });
    }

    updateEmployee = () => {
        const {payroll, employer} = this.props;
        payroll.updateEmployee(this.employeeInput.value, parseInt(this.salaryInput.value), {
            from: employer,
            gas: 1000000
        }).then((result) => {
            alert('success');
        });
    }

    removeEmployee = () => {
        const {payroll, employer} = this.props;
        payroll.removeEmployee(this.removeEmployeeInput.value, {
            from: employer,
            gas: 1000000
        }).then((result) => {
            alert('success');
        });
    }
    
    render() {
        return (
            <div>
                <h2>Employer</h2>
                <form className="pure-form pure-form-stacked">
                    <fieldset>
                        <legend>增加资金</legend>

                        <label>资金</label>
                        <input 
                            type="text"
                            placeholder="fund"
                            ref={(input) => {this.fundInput = input;}}/>
                        
                        <button type="button" className="pure-button" onClick={this.addFund}>Add</button>
                    </fieldset>
                </form>

                <form className="pure-form pure-form-stacked">
                    <fieldset>
                        <legend>增加/更新员工</legend>

                        <label>员工地址</label>
                        <input 
                            type="text"
                            placeholder="employee"
                            ref={(input) => {this.employeeInput = input;}}/>

                        <label>工资</label>
                        <input 
                            type="text"
                            placeholder="salary"
                            ref={(input) => {this.salaryInput = input;}}/>

                        <button type="button" className="pure-button" onClick={this.addEmployee}>增加</button>
                        <button type="button" className="pure-button" onClick={this.updateEmployee}>更新</button>
                    </fieldset>
                </form>

                <form className="pure-form pure-form-stacked">
                    <fieldset>
                        <legend>删除员工</legend>

                        <label>员工地址</label>
                        <input
                            type="text"
                            placeholder="employee"
                            ref={(input) => {this.removeEmployeeInput = input;}}/>
                        
                        <button type="button" className="pure-button" onClick={this.removeEmployee}>删除</button>
                    </fieldset>
                </form>
            </div>
        )
    }
}

export default Employer