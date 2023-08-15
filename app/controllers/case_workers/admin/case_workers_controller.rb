module CaseWorkers
  module Admin
    class CaseWorkersController < CaseWorkers::Admin::ApplicationController
      include PasswordHelpers

      before_action :set_case_worker, only: %i[show edit update destroy change_password update_password]

      def index
        @case_workers = CaseWorker.includes(:location).joins(:user)
        query = "lower(users.first_name || ' ' || users.last_name) ILIKE :term"
        @case_workers = @case_workers.where(query, term: "%#{params[:search]}%") if params[:search].present?
        @case_workers = @case_workers.order('users.last_name', 'users.first_name')
      end

      def show; end

      def new
        @case_worker = CaseWorker.new
        @case_worker.build_user
      end

      def edit; end

      def change_password; end

      def create
        @case_worker = CaseWorker.new(params_with_temporary_password)
        if @case_worker.save
          deliver_reset_password_instructions(@case_worker.user)
          redirect_to case_workers_admin_case_workers_url, notice: t('.notice')
        else
          render :new
        end
      end

      def update
        if @case_worker.update(case_worker_params)
          redirect_to case_workers_admin_case_workers_url, notice: t('.notice')
        else
          render :edit
        end
      end

      # NOTE: update_password in PasswordHelper

      def destroy
        @case_worker.soft_delete
        redirect_to case_workers_admin_case_workers_url, notice: t('.notice')
      end

      private

      def set_case_worker
        @case_worker = CaseWorker.active.find(params[:id])
      end

      def case_worker_params
        attributes = %i[id email email_confirmation current_password password password_confirmation first_name
                        last_name]
        params.require(:case_worker).permit(
          :location_id,
          user_attributes: attributes,
          claim_ids: [],
          roles: []
        )
      end
    end
  end
end
