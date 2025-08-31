import React from 'react';
import { connect } from 'react-redux';
import ModalBase from './ModalBase';
import { NewThreadForm } from './PostForm';


function mapStateToProps(state) {
    return {};
}

function NewThreadModal(props) {
    return (
        <ModalBase menu_id="newThreadLink" form_id="postForm">
          <NewThreadForm action="/threads/new" {...props}/>
        </ModalBase>
    );
}

export default connect(mapStateToProps)(NewThreadModal);
