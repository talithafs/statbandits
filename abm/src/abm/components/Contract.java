package abm.components;

public class Contract {
	
	private double ratePerFarmer ;
	private double banditsMultiplier ; 
	private double proposedRate ;
	private double secTax ;
	
	public double getSecTax() {
		return secTax;
	}

	public void setSecTax(double secTax) {
		this.secTax = secTax;
	}

	public Contract(double rpf, double tau, double rpb, double stax) {
		this.ratePerFarmer = rpf;
		this.proposedRate = tau;
		this.banditsMultiplier = rpb ;
		this.secTax = stax ; 
	}
	
	public double getRatePerFarmer() {
		return ratePerFarmer;
	}
	
	public void setRatePerFarmer(double rpf) {
		this.ratePerFarmer = rpf;
	}
	
	public double getProposedRate() {
		return proposedRate;
	}
	
	public void setProposedRate(double tau) {
		this.proposedRate = tau;
	}
	
	public double getBanditsMultiplier() {
		return banditsMultiplier;
	}
	
	public void setBanditsMultiplier(double ratePerBandit) {
		this.banditsMultiplier = ratePerBandit;
	}

}
