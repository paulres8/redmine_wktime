class WkcontactController < WkcrmController
  unloadable



	def index
		set_filter_session
		contactName = session[:wkcontact][:contactname] 			
		accountId =  session[:wkcontact][:account_id]
		wkcontact = nil
		if !contactName.blank? &&  !accountId.blank?
			wkcontact = WkCrmContact.where(:parent_id => accountId, :parent_type => "WkAccount").where("LOWER(wk_crm_contacts.first_name) like LOWER(?) OR LOWER(wk_crm_contacts.last_name) like LOWER(?)", "%#{contactName}%", "%#{contactName}%")
		elsif contactName.blank? &&  !accountId.blank? 
			wkcontact = WkCrmContact.where(:parent_id => accountId, :parent_type => "WkAccount")
		elsif !contactName.blank? &&  accountId.blank?
			wkcontact = WkCrmContact.where("LOWER(wk_crm_contacts.first_name) like LOWER(?) OR LOWER(wk_crm_contacts.last_name) like LOWER(?)", "%#{contactName}%", "%#{contactName}%")
		else
			wkcontact = WkCrmContact.where("parent_type = 'WkAccount' or parent_type is null ")
		end	
		formPagination(wkcontact)
	end

	def edit
		@conEditEntry = nil		
		unless params[:contact_id].blank?
			@conEditEntry = WkCrmContact.where(:id => params[:contact_id].to_i)
		end
	end
	
	def update
		errorMsg = nil
		if params[:contact_id].blank?
		    wkContact = WkCrmContact.new 
	    else
		    wkContact = WkCrmContact.find(params[:contact_id].to_i)
	    end
		# For Contact table
		wkContact.assigned_user_id = params[:assigned_user_id]
		wkContact.first_name = params[:first_name]
		wkContact.last_name = params[:last_name]
		wkContact.address_id = params[:address_id]
		wkContact.title = params[:contact_title]
		wkContact.description = params[:description]
		wkContact.department = params[:department]
		wkContact.salutation = params[:salutation]
		wkContact.parent_id = params[:account_id]
		wkContact.parent_type = "WkAccount"
		wkContact.created_by_user_id = User.current.id if wkContact.new_record?
		wkContact.updated_by_user_id = User.current.id
		addrId = updateAddress
		unless addrId.blank?
			wkContact.address_id = addrId
		end
		unless wkContact.valid?		
			errorMsg = wkContact.errors.full_messages.join("<br>")	
		else
			wkContact.save
		end
		
		if errorMsg.blank?
			redirect_to :controller => 'wkcontact',:action => 'index' , :tab => 'wkcontact'
		    flash[:notice] = l(:notice_successful_update)
		else
			flash[:error] = errorMsg
		    redirect_to :controller => 'wkcontact',:action => 'edit'
		end
		
	end
	
	def destroy
	end
	
	 def set_filter_session
        if params[:searchlist].blank? && session[:wkcontact].nil?
			session[:wkcontact] = {:contactname => params[:contactname], :account_id => params[:account_id] }
		elsif params[:searchlist] =='wkcontact'
			session[:wkcontact][:contactname] = params[:contactname]
			session[:wkcontact][:account_id] = params[:account_id]
		end
		
    end
	
	def formPagination(entries)
		@entry_count = entries.count
        setLimitAndOffset()
		@contact = entries.order(updated_at: :desc).limit(@limit).offset(@offset)
	end
	
	def setLimitAndOffset		
		if api_request?
			@offset, @limit = api_offset_and_limit
			if !params[:limit].blank?
				@limit = params[:limit]
			end
			if !params[:offset].blank?
				@offset = params[:offset]
			end
		else
			@entry_pages = Paginator.new @entry_count, per_page_option, params['page']
			@limit = @entry_pages.per_page
			@offset = @entry_pages.offset
		end	
	end

end
