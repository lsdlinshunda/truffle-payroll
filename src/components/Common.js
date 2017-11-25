import React, { Component } from 'react'
import { Card, Col, Row} from 'antd';

class Common extends Component {
    constructor(props) {
        super(props);

        this.state = {};
    }

    componentDidMount() {
        const { payroll, web3 } = this.props;

        //event回调函数
        const updateInfo = (error, result) => {
            console.log(1);
            if (!error) {
                this.checkInfo();
            }
        }

        this.newFund = payroll.NewFund();
        this.getPaid = payroll.GetPaid();
        this.newEmployee = payroll.NewEmployee();
        this.updateEmployee = payroll.UpdateEmployee();
        this.removeEmployee = payroll.RemoveEmployee();

        //事件监听
        this.newFund.watch(updateInfo);
        this.getPaid.watch(updateInfo);
        this.newEmployee.watch(updateInfo);
        this.updateEmployee.watch(updateInfo);
        this.removeEmployee.watch(updateInfo);

        this.checkInfo();
    }

    //解除事件监听
    componentWillUnmount() {
        this.newFund.stopWatching();
        this.getPaid.stopWatching();
        this.newEmployee.stopWatching();
        this.updateEmployee.stopWatching();
        this.removeEmployee.stopWatching();
    }

    checkInfo = () => {
        const { payroll, web3, account } = this.props;
        payroll.checkInfo.call({
            from: account,
        }).then((result) => {
            this.setState({
                balance: web3.fromWei(result[0].toNumber()),
                runway: result[1].toNumber(),
                employeeCount: result[2].toNumber()
            })
        });
    }

    render() {
        const { runway, balance, employeeCount } = this.state;
        return (
            <div>
                <h2>通用信息</h2>
                <Row gutter={16}>
                    <Col span={8}>
                        <Card title="合约金额">{balance} Ether</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="员工人数">{employeeCount}</Card>
                    </Col>
                    <Col span={8}>
                        <Card title="可支付次数">{runway}</Card>
                    </Col>
                </Row>
            </div>
        );
    }
}

export default Common
