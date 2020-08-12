package abm.agents;

import abm.helpers.Utils;

public class Agent {

	// State variables
	protected double income;
	protected boolean isVoter;

	// Auxiliary variables
	private static int idCounter = 0;
	private int id;

	public Agent() {
		this.id = idCounter++;
	}

	public Agent(double income, boolean isVoter) {
		this.income = income;
		this.isVoter = isVoter;
		this.id = idCounter++;
	}

	public double getIncome() {
		return income;
	}

	public void setIncome(double income) {
		this.income = income;
	}

	public int getId() {
		return id;
	}

	public boolean isVoter() {
		return isVoter;
	}

	public void vote() {

	}

	public double receiveIncome(double income) {
		this.income = income;
		return this.income;
	}

	public int chooseAction(double rate, double prodAdvantage) {
		return -1;
	}

	@Override
	public boolean equals(Object obj) {

		if (obj instanceof Agent) {

			if (((Agent) obj).getId() == this.id) {
				return true;
			}

			return false;
		}

		return false;
	}

	@Override
	public String toString() {

		Integer id = this.id;
		Double income = this.income;
		Boolean isVoter = this.isVoter;
		// Double netWorth = this.netWorth ;

		String[][] fields = { { "Id", id.toString() }, { "Income", income.toString() },
				{ "Voter", isVoter.toString() } };

		return Utils.getAgentDescriptor(fields, true);
	}

}
