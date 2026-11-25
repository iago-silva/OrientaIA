class TrainingController < ApplicationController
  before_action :require_student!

  def show
    @step = params[:step].to_i.clamp(0, 2)
    @step = [ @step, current_student.training_step ].min unless current_student.trained?
  end

  def update
    current_student.with_lock do
      case params[:step].to_i
      when 0
        current_student.update!(training_step: [ current_student.training_step, 1 ].max)
      when 1
        return redirect_to training_path(step: 1), alert: "Confira sua resposta: verifique a fonte e discuta a dúvida com sua orientadora." unless params[:answer] == "verify"
        return redirect_to training_path(step: 0), alert: "Conclua a primeira etapa." if current_student.training_step < 1
        current_student.update!(training_step: 2)
      when 2
        return redirect_to training_path(step: 1), alert: "Conclua a leitura e a prática antes de continuar." if current_student.training_step < 2
        return redirect_to training_path(step: 2), alert: "Confirme seu compromisso de uso para concluir." unless params[:commitment] == "1"
        current_student.update!(training_step: 3, training_completed_at: Time.current)
        return redirect_to root_path, notice: "Formação concluída. Seu espaço acadêmico está liberado."
      end
    end
    redirect_to training_path(step: current_student.training_step)
  end
end
